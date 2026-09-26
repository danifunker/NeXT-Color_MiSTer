#!/usr/bin/env python3
"""Disassemble the NeXTstation Turbo Color boot ROM (Rev 3.3 v74) into rom-dissassembly/.

Method: recursive descent (Capstone M68K, 68040 mode) from the reset vector,
from every longword in the image that points into the ROM (function tables,
the monitor command table, the exception handler table) and from every C
function prologue (`link a6,#n` preceded by `rts`/`unlk a6`/`nop`) that the
descent did not reach, with ASCII strings found first so code never runs into
them.  Everything reached is code; everything else is data (strings, ROM
pointer tables, or hex).  Absolute NeXT addresses are annotated from Previous's
ioMemTabTurbo.c plus the TMC/ADB/NCC/RAMDAC/VRAM/RAM regions of the Turbo
memory map.  Names of routines identified in the v66 (non-Turbo) ROM are ported
automatically by byte-pattern matching where the code is identical.

    python rom-dissassembly/disasm_rom.py          # from the repo root

Environment: PREVIOUS_SRC may point at a Previous source tree (for
ioMemTabTurbo.c and Rev_2.5_v66.BIN); default is ../previous-code-r1851-trunk/src.
"""
import os, re, struct, sys
from collections import defaultdict
from capstone import Cs, CS_ARCH_M68K, CS_MODE_M68K_040, CS_MODE_BIG_ENDIAN

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
ROM_PATH = os.path.join(ROOT, "roms", "Rev_3.3_v74.BIN")
PREVIOUS = os.environ.get("PREVIOUS_SRC", os.path.join(ROOT, "..", "previous-code-r1851-trunk", "src"))
IOTAB = os.path.join(PREVIOUS, "ioMemTabTurbo.c")
V66_PATH = os.path.join(PREVIOUS, "Rev_2.5_v66.BIN")
OUT = HERE
BASE = 0x01000000
ROM_NAME = "Rev_3.3_v74"

rom = open(ROM_PATH, "rb").read()
SIZE = len(rom)
END = BASE + SIZE

# ---------------------------------------------------------------- known names (v74 addresses)
# Names given by hand for this ROM.  Entries for the v66 ROM (below) are ported
# automatically by byte matching; anything listed here wins over a ported name.
KNOWN = {
    0x0100001e: ("reset_entry", "reset vector target (ROM offset 4)"),
}
try:
    from known_names import KNOWN as _EXTRA
    KNOWN.update(_EXTRA)
except ImportError:
    pass

# Routines named in the v66 (NeXTcube non-Turbo, NeXT_MiSTer/rom-disassembly) listing.
# Ported to v74 where the first bytes of the routine are found exactly once in v74.
KNOWN_V66 = {
    0x010024cc: ("delay_us", "delay(n us): calibrated dbf self-loop (v66 name)"),
    0x010024f0: ("delay_loop", "the calibrated dbf d0,* loop"),
    0x01001330: ("post_passed_path", "System test passed path"),
    0x010031b4: ("post_fpu_test", "POST: FPU test entry"),
    0x010031fa: ("post_scc_test", "POST: SCC test entry"),
    0x0100337e: ("post_scsi_test", "POST: SCSI test entry"),
    0x01003430: ("post_ext_scsi_test", "POST: Extended SCSI test entry"),
    0x01003548: ("post_enet_test", "POST: Ethernet test entry"),
    0x0100381a: ("post_ecc_test", "POST: ECC test entry"),
    0x01003b1a: ("post_rtc_test", "POST: RTC test entry"),
    0x01003b98: ("post_timer_test", "POST: Timer test entry"),
    0x01003c7e: ("post_evcnt_test", "POST: Event counter test entry"),
    0x01003d78: ("post_evcnt_measured", "POST: event counter measured delay(1000) in d0 (us)"),
    0x01003f74: ("post_sndout_test", "POST: Sound out test entry"),
    0x010046f2: ("post_ret_fpu", "POST master: FPU test returned (d0)"),
    0x0100471c: ("post_ret_scc", "POST master: SCC test returned (d0)"),
    0x01004746: ("post_ret_scsi", "POST master: SCSI test returned (d0)"),
    0x01004764: ("post_ret_enet", "POST master: Enet test returned (d0)"),
    0x0100479c: ("post_ret_ecc", "POST master: ECC test returned (d0)"),
    0x010047c6: ("post_ret_rtc", "POST master: RTC test returned (d0)"),
    0x010047f0: ("post_ret_timer", "POST master: Timer test returned (d0)"),
    0x0100481a: ("post_ret_evcnt", "POST master: Event counter test returned (d0)"),
    0x01004852: ("post_ret_sndout", "POST master: Sound out test returned (d0)"),
    0x01004884: ("post_ret_ext_scsi", "POST master: Extended SCSI test returned (d0)"),
}

PORTED = {}   # v74 addr -> (name, note, v66 addr)
if os.path.exists(V66_PATH):
    v66 = open(V66_PATH, "rb").read()
    for a66, (name, note) in KNOWN_V66.items():
        o = a66 - BASE
        for n in (32, 24, 16, 12):
            pat = v66[o:o + n]
            hits = [m.start() for m in re.finditer(re.escape(pat), rom)]
            if len(hits) == 1:
                PORTED[BASE + hits[0]] = (name, note + " [ported from v66 %08x by %d-byte match]" % (a66, n), a66)
                break
for a, (name, note, _) in PORTED.items():
    KNOWN.setdefault(a, (name, note))

# ---------------------------------------------------------------- I/O map (Turbo)
io = {}          # addr -> (section, name)
io_sections = [] # (addr, section) in file order for range fallback
section = ""
if os.path.exists(IOTAB):
    for line in open(IOTAB, encoding="utf-8", errors="replace"):
        m = re.match(r"\s*/\*\s*(.*?)\s*\*/\s*$", line)
        if m and "{" not in line:
            section = m.group(1); continue
        m = re.match(r"\s*\{\s*0x([0-9a-fA-F]+)\s*,\s*0x[0-9a-fA-F]+\s*,\s*SIZE_(\w+)\s*,\s*(\w+)\s*,\s*(\w+)\s*\}\s*,?\s*(?:/\*\s*(.*?)\s*\*/)?", line)
        if m:
            a = int(m.group(1), 16)
            rd, wr = m.group(3), m.group(4)
            def strip(f):
                f = re.sub(r"^IoMem_(Read|Write)WithoutInterception(ButTrace)?$", "unhandled", f)
                return re.sub(r"_(Read|Write)$", "", f)
            name = strip(rd) if strip(rd) == strip(wr) else strip(rd) + "/" + strip(wr)
            if m.group(5): name += " (" + m.group(5) + ")"
            io[a] = (section, name)
            if not io_sections or io_sections[-1][1] != section:
                io_sections.append((a, section))
else:
    print("warning: %s not found; device registers will not be named" % IOTAB, file=sys.stderr)

# Turbo Memory Controller (tmc.c) and ADB (adb.c) registers, not in the ioMem table
TMC = {
    0x02200000: "TMC SCR1 (system control 1: cpu speed[2:0], mem speed[5:4], vmem speed[7:6], cpu rev[11:8], cpu type[15:12] (5=Turbo Color), slot id[31:28])",
    0x02200010: "TMC control register (bit8 local-only, bit9 ROM-local, bit10 parity; reset 0x0D17038F)",
    0x02200020: "TMC NMI register (bit0 of byte 3 at +0x23)",
    0x02200080: "TMC video interrupt register (byte 0: bit0 intr, bit1 int mask, bit2 enable)",
    0x02200088: "TMC horizontal config (fporch[31:25] sync[24:19] bporch[18:12] display[11:0])",
    0x0220008c: "TMC vertical config (fporch[31:25] sync[24:19] bporch[18:12] display[11:0])",
}
ADB = {0x00: "ADB_INTSTATUS", 0x08: "ADB_INTMASK", 0x10: "ADB_SETINT", 0x18: "ADB_CONFIG", 0x20: "ADB_CTRL",
       0x28: "ADB_STATUS", 0x30: "ADB_CMD", 0x38: "ADB_COUNT", 0x80: "ADB_DATA0", 0x88: "ADB_DATA1"}
for off, n in ADB.items():
    TMC[0x02208000 + off] = "ADB %s (TMC ADB window)" % n
for a, n in TMC.items():
    io[a] = ("Turbo Memory Controller", n)
io_addrs = sorted(io)

# Memory regions of the Turbo Color machine (Previous cpu/memory.c, tmc.c, ncc.c)
REGIONS = [
    (0x00000000, 0x00000008, "reset vectors (ROM alias)"),
    (0x00000000, 0x01000000, "low memory (ROM alias at reset / exception vectors after MMU/TMC setup)"),
    (0x01000000, 0x02000000, "ROM"),
    (0x02000000, 0x02020000, "device space"),
    (0x02020000, 0x02030000, "NBIC (non-Turbo cube only)"),
    (0x020C0000, 0x020D0000, "BMAP (non-Turbo only)"),
    (0x02100000, 0x02120000, "device space mirror (BMAP path on non-Turbo; plain I/O on Turbo)"),
    (0x02200000, 0x02210000, "TMC register space"),
    (0x02210000, 0x02220000, "NCC (Nitro cache controller, 40 MHz boards only)"),
    (0x03E00000, 0x03F00000, "NCC cache tag RAM"),
    (0x03F00000, 0x04000000, "NCC cache data RAM"),
    (0x04000000, 0x06000000, "RAM bank 0 (Turbo: 32 MB stride)"),
    (0x06000000, 0x08000000, "RAM bank 1"),
    (0x08000000, 0x0A000000, "RAM bank 2"),
    (0x0A000000, 0x0C000000, "RAM bank 3"),
    (0x0C000000, 0x0D000000, "VRAM (Turbo; color 2 MB at $0C000000)"),
    (0x0D000000, 0x10000000, "VRAM MWF mirrors (non-Turbo mono only)"),
    (0x10000000, 0x20000000, "RAM MWF mirrors (non-Turbo mono only)"),
    (0x2C000000, 0x2D000000, "color VRAM (non-Turbo color station)"),
    (0x820C0000, 0x820D0000, "BMAP alias (non-Turbo)"),
    (0xF0000000, 0x100000000, "NextBus slot space"),
]
def region_of(a):
    best = None
    for lo, hi, n in REGIONS:
        if lo <= a < hi:
            if best is None or (hi - lo) < (best[1] - best[0]): best = (lo, hi, n)
    return best[2] if best else None

def io_annot(a):
    """name for an absolute address in NeXT device/TMC space"""
    dev = 0x02000000 <= a < 0x02220000 or (a >> 16) in (0x020C, 0x820C)
    if not dev:
        return None
    if a in io: return "%s: %s" % io[a]
    lo = [x for x in io_addrs if x <= a and a - x < 16]
    if lo:
        x = lo[-1]; return "%s: %s+%d" % (io[x][0], io[x][1], a - x)
    if 0x02200000 <= a < 0x02210000:
        if 0x02208000 <= a < 0x02208100: return "ADB window (TMC) +$%x" % (a - 0x02208000)
        return "TMC +$%x" % (a - 0x02200000)
    if 0x02210000 <= a < 0x02220000: return "NCC +$%x" % (a - 0x02210000)
    if (a >> 16) in (0x020C, 0x820C): return "BMAP chip (non-Turbo)"
    if 0x02020000 <= a < 0x02030000: return "NBIC (non-Turbo cube) +$%x" % (a - 0x02020000)
    if 0x02120000 <= a < 0x02200000: return None
    if 0x02100000 <= a < 0x02120000:
        b = a - 0x00100000
        inner = io_annot(b)
        return "device space mirror of $%08x%s" % (b, (" = " + inner) if inner else "")
    sec = [s for x, s in io_sections if x <= a]
    return sec[-1] if sec else "device space"

def abs_annot(a):
    """annotation for any absolute non-ROM address"""
    n = io_annot(a)
    if n: return n
    r = region_of(a)
    if r and not (BASE <= a < END): return r
    return None

is_str = bytearray(SIZE)
strings = {}
def printable(c): return 0x20 <= c < 0x7f or c in (0x0a, 0x0d, 0x09)
# ---------------------------------------------------------------- pointers
def rd16(off): return struct.unpack(">H", rom[off:off + 2])[0]
def rd32(off): return struct.unpack(">I", rom[off:off + 4])[0]
def rom_ptr(v): return BASE <= v < END and (v & 1) == 0

ptr_targets = defaultdict(list)   # target addr -> [source addr]
for off in range(0, SIZE - 3, 2):
    v = rd32(off)
    if rom_ptr(v):
        ptr_targets[v].append(BASE + off)

# ---------------------------------------------------------------- descent
md = Cs(CS_ARCH_M68K, CS_MODE_M68K_040 | CS_MODE_BIG_ENDIAN)
insns = {}       # addr -> (size, mnemonic, op_str, bytes)
code = bytearray(SIZE)   # 1 = instruction start, 2 = continuation
xref_call = defaultdict(set)   # target -> {from}
xref_jump = defaultdict(set)
xref_data = defaultdict(set)   # data addr -> {from insn}
sub_starts = set()
loc_starts = set()
seed_kind = {}
bad_stops = {}

STOP = {"rts", "rte", "rtr", "rtd", "jmp", "bra", "illegal", "stop", "reset"}
CALLS = {"bsr", "jsr"}
BR = re.compile(r"^(b[a-z]{2}|bra|bsr|dbra|db[a-z]{2}|jmp|jsr)(\.[bwl])?$")

def targets_of(ins):
    """absolute targets ($hex) named in a branch/jump operand"""
    if not BR.match(ins.mnemonic): return []
    out = []
    for m in re.finditer(r"\$([0-9a-f]+)", ins.op_str):
        v = int(m.group(1), 16)
        if BASE <= v < END: out.append(v)
    return out

class Ins:
    def __init__(self, address, size, mnemonic, op_str):
        self.address, self.size, self.mnemonic, self.op_str = address, size, mnemonic, op_str
        self.bytes = rom[address - BASE:address - BASE + size]

def ea_len(mode, reg, off):
    """extension-word bytes of an effective address (for the fallback decoder)"""
    if mode in (2, 3, 4): return 0
    if mode == 5: return 2
    if mode == 6:
        ext = rd16(off)
        if not (ext & 0x100): return 2
        bd = (ext >> 4) & 3; od = ext & 3
        return 2 + {0: 0, 1: 0, 2: 2, 3: 4}[bd] + {0: 0, 1: 0, 2: 2, 3: 4}[od]
    if mode == 7: return {0: 2, 1: 4, 2: 2, 3: 2, 4: 4}.get(reg, 0)
    return 0

def ea_str(mode, reg, off):
    if mode == 2: return "(a%d)" % reg
    if mode == 3: return "(a%d)+" % reg
    if mode == 4: return "-(a%d)" % reg
    if mode == 5: return "$%x(a%d)" % (struct.unpack(">h", rom[off:off + 2])[0], reg)
    if mode == 6: return "(idx,a%d)" % reg
    if mode == 7 and reg == 1: return "$%08x.l" % rd32(off)
    if mode == 7 and reg == 0: return "$%x.w" % struct.unpack(">h", rom[off:off + 2])[0]
    return "ea(%d,%d)" % (mode, reg)

def decode040(addr):
    """68040 instructions Capstone 5 does not decode: PFLUSH*, PTEST, MOVE16,
    FSAVE/FRESTORE, CINV/CPUSH.  Returns an Ins or None."""
    off = addr - BASE
    w = rd16(off)
    reg = w & 7
    if w & 0xFFE0 == 0xF500:                       # pflush
        return Ins(addr, 2, ("pflushn", "pflush", "pflushan", "pflusha")[(w >> 3) & 3], "" if w & 0x10 else "(a%d)" % reg)
    if w & 0xFFD8 == 0xF548:                       # ptest
        return Ins(addr, 2, "ptestr" if w & 0x20 else "ptestw", "(a%d)" % reg)
    if w & 0xFF80 == 0xF400 and (w >> 3) & 7 != 0: # cinv/cpush
        cache = ("nc", "dc", "ic", "bc")[(w >> 6) & 3]
        scope = (w >> 3) & 3
        op = "cpush" if w & 0x20 else "cinv"
        return Ins(addr, 2, op + ("", "l", "p", "a")[scope], cache if scope == 3 else "%s, (a%d)" % (cache, reg))
    if w & 0xFFC0 == 0xF300 or w & 0xFFC0 == 0xF340:   # fsave / frestore
        mode = (w >> 3) & 7
        return Ins(addr, 2 + ea_len(mode, reg, off + 2), "frestore" if w & 0x40 else "fsave", ea_str(mode, reg, off + 2))
    if w & 0xFFE0 == 0xF620:                       # move16 (ax)+,(ay)+
        w2 = rd16(off + 2)
        return Ins(addr, 4, "move16", "(a%d)+, (a%d)+" % (reg, (w2 >> 12) & 7))
    if w & 0xFFE0 == 0xF600:                       # move16 with absolute long
        form = (w >> 3) & 3
        absl = "$%08x.l" % rd32(off + 2)
        ops = ("(a%d)+, %s" % (reg, absl), "%s, (a%d)+" % (absl, reg), "(a%d), %s" % (reg, absl), "%s, (a%d)" % (absl, reg))[form]
        return Ins(addr, 6, "move16", ops)
    return None

def dis1(addr):
    off = addr - BASE
    for ins in md.disasm(rom[off:off + 12], addr, count=1):
        if ins.mnemonic != ".byte":
            return Ins(addr, ins.size, ins.mnemonic, ins.op_str)
        break
    return decode040(addr)

def descend(seed, kind):
    work = [seed]
    while work:
        a = work.pop()
        while True:
            if a < BASE or a >= END or (a & 1): break
            off = a - BASE
            if code[off] or is_str[off]: break
            ins = dis1(a)
            if ins is None:
                bad_stops[a] = kind; break
            n = ins.size
            if off + n > SIZE: break
            if any(is_str[off:off + n]) or any(code[off + 1:off + n]): break
            insns[a] = (n, ins.mnemonic, ins.op_str, rom[off:off + n])
            code[off] = 1
            for k in range(off + 1, off + n): code[k] = 2
            mn = ins.mnemonic.split(".")[0]
            for t in targets_of(ins):
                if mn in CALLS:
                    xref_call[t].add(a); sub_starts.add(t)
                else:
                    xref_jump[t].add(a); loc_starts.add(t)
                work.append(t)
            if not BR.match(ins.mnemonic):
                for m in re.finditer(r"\$([0-9a-f]+)", ins.op_str):
                    v = int(m.group(1), 16)
                    if BASE <= v < END: xref_data[v].add(a)
            if mn in STOP: break
            a += n

# strings first, so the descent never runs into text
DATA_START = 0x01012c00 - BASE   # strings and tables live from here on
def find_strings(minlen=4, strict=False):
    """strict: before the descent, only accept text that cannot be code: in the
    data tail, or referenced by a longword pointer somewhere in the ROM"""
    i = 0
    while i < SIZE:
        j = i
        while j < SIZE and printable(rom[j]) and code[j] not in (1, 2): j += 1
        if j - i >= minlen and j < SIZE and rom[j] == 0 and code[i] not in (1, 2):
            txt = rom[i:j]
            ok = re.search(rb"[A-Za-z]{2}", txt) is not None
            if ok and strict and i < DATA_START and (BASE + i) not in ptr_targets:   # code-region strings are always addressed by a 32-bit pointer
                ok = False
            # rts/unlk/nop/link opcodes (4e75 4e5e 4e71 4e56) read as "Nu" "N^" "Nq" "NV"
            if ok and len(txt) < 8 and re.match(rb"^N[u^qV]", txt):
                ok = False
            # a 4-5 char run of mixed-case letters with no space/digit is almost
            # always opcodes ("NqNV" = nop; link a6), not text
            if ok and len(txt) < 6 and not re.search(rb"[ 0-9_.:/%-]", txt) and re.search(rb"[A-Z]", txt) and re.search(rb"[a-z]", txt):
                ok = False
            if ok and re.search(rb"(N\^Nu|NuNq|NqNV|N\^NuNV)", txt) and not re.search(rb"[ ]", txt):   # unlk/rts/nop/link byte runs
                ok = False
            if ok:
                strings[i] = txt
                for k in range(i, j + 1): is_str[k] = 1
                i = j + 1; continue
        i += 1
find_strings(6, strict=True)

sub_starts.add(rd32(4)); seed_kind[rd32(4)] = "reset"
descend(rd32(4), "reset")
def looks_text(off):
    return all(printable(c) or c == 0 for c in rom[off:off + 12]) and sum(1 for c in rom[off:off + 12] if printable(c)) >= 8
# byte ranges that hold only data (switch jump tables; the ROM tail: string block, register/parameter
# tables, help text, keymaps, fonts, bitmaps, device tables).  Never decoded as code.
DATA_RANGES = [(0x01011bf0, 0x01012c00), (0x01012c00, END)]
def in_data(a): return any(lo <= a < hi for lo, hi in DATA_RANGES)
for lo, hi in DATA_RANGES:
    for k in range(lo - BASE, hi - BASE): 
        if not is_str[k]: code[k] = 3          # 3 = declared data (blocks the descent)
ptr_seeds_ok = set()
EXTRA_CODE = {0x01003ee8: "mem_parity_probe (bsr.l from 01003806)", 0x0100670a: "boot_l3_isr (jsr from sub_010068be)",
              0x01007e0c: "abs_l (called from 01008b8a)", 0x010041f2: "crc32 C wrapper"}
for a in list(KNOWN) + list(EXTRA_CODE):
    if not code[a - BASE] and not is_str[a - BASE]:
        sub_starts.add(a); seed_kind.setdefault(a, "known")
        descend(a, "known")
def seed_prologues():
    """C function prologues the descent did not reach: `link a6,#n` right after
    `rts`, `unlk a6; rts`, `nop`, `jmp`, `bra` or `rte`"""
    for off in range(0x1e, SIZE - 4, 2):
        if code[off] or is_str[off] or in_data(BASE + off): continue
        if rd16(off) != 0x4e56: continue
        prev = rd16(off - 2)
        if prev in (0x4e75, 0x4e71, 0x4e73, 0x4ed0, 0x4ed1) or (prev & 0xff00) == 0x6000 or (prev & 0xffc0) == 0x4ec0:
            a = BASE + off
            sub_starts.add(a); seed_kind.setdefault(a, "prologue")
            descend(a, "prologue")
seed_prologues()
# addresses that are pointed to but are data (exception vector tables loaded with movec vbr, etc.)
NOT_CODE = {0x010145b0, 0x010145bc, 0x01003fc2, 0x01003ff2, 0x010195f4, 0x01011bf0, 0x01011c20, 0x01011c40}
for t in sorted(ptr_targets):
    off = t - BASE
    if code[off] or is_str[off] or looks_text(off) or off < 0x1e: continue   # header longs are not code
    if t in NOT_CODE or rd16(off) == 0 or in_data(t): continue   # a zero word (ori.b #0,d0) never starts a routine
    def addr_operand(src):
        """True if the longword at src is an address operand (lea/pea/movea) of a decoded instruction, or not inside code at all"""
        o = src - BASE
        if not code[o]: return True
        for back in range(0, 8, 2):
            ins = insns.get(BASE + o - back)
            if ins and ins[0] > back:
                return ins[1].startswith(("lea", "pea", "movea"))
        return False
    if not any(addr_operand(src) for src in ptr_targets[t]) and not any(in_data(src) for src in ptr_targets[t]):
        continue   # every "pointer" to it is a plain immediate inside an instruction, not a table entry or an address load
    ins = dis1(t)
    if ins is None: continue
    ptr_seeds_ok.add(t)
    sub_starts.add(t); seed_kind.setdefault(t, "ptr")
    descend(t, "ptr")
seed_prologues()
# strings again now that more code is known (a string range never overlaps code)
find_strings()

# ---------------------------------------------------------------- labels
labels = {}
for a in KNOWN: labels[a] = KNOWN[a][0]
for a in sub_starts:
    if a not in labels and code[a - BASE] == 1: labels[a] = "sub_%08x" % a
for a in loc_starts:
    if a not in labels and code[a - BASE] == 1: labels[a] = "loc_%08x" % a
for off in strings:
    labels.setdefault(BASE + off, "str_%08x" % (BASE + off))
for t in ptr_targets:
    off = t - BASE
    if t not in labels and (t in ptr_seeds_ok or code[off] != 1 or any(in_data(src) or not code[src - BASE] for src in ptr_targets[t])):
        labels[t] = ("sub_%08x" if code[off] == 1 else "dat_%08x") % t
for t in xref_data:
    labels.setdefault(t, "dat_%08x" % t)

def sym(v):
    return labels.get(v)

def annotate_ops(op_str):
    """replace absolute ROM addresses with labels, annotate I/O and memory-region addresses"""
    notes = []
    def rep(m):
        v = int(m.group(1), 16)
        s = sym(v)
        if s: return s
        n = abs_annot(v)
        if n: notes.append("$%08x = %s" % (v, n))
        return m.group(0)
    s = re.sub(r"\$([0-9a-f]{6,8})\b", rep, op_str)
    return s, notes

# ---------------------------------------------------------------- listing
def esc(txt):
    parts, cur = [], ""
    for c in txt:
        if 0x20 <= c < 0x7f and c not in (0x22, 0x5c):
            cur += chr(c)
        else:
            if cur: parts.append('"%s"' % cur); cur = ""
            parts.append("$%02x" % c)
    if cur: parts.append('"%s"' % cur)
    return ",".join(parts)

def show(s):
    return s.decode("latin-1").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t")

lines = []
def emit(s=""): lines.append(s)

emit("; NeXTstation Turbo Color boot ROM Rev 3.3 v74 (roms/Rev_3.3_v74.BIN)")
emit("; %d bytes at $%08X (also aliased at $00000000 for the reset vectors)" % (SIZE, BASE))
emit("; generated by rom-dissassembly/disasm_rom.py -- see README.md for conventions")
emit(";")
emit("; columns: address  bytes  mnemonic operands  ; notes / xrefs")
emit("")
emit("; ROM header (see README.md)")
emit("%08x  %s  dc.l $%08x  ; initial SSP" % (BASE, rom[0:4].hex(), rd32(0)))
emit("%08x  %s  dc.l $%08x  ; initial PC -> %s" % (BASE + 4, rom[4:8].hex(), rd32(4), sym(rd32(4)) or ""))
emit("%08x  %s  dc.b %s  ; Ethernet MAC address (Previous rom.c patches bytes 3-5)" % (BASE + 8, rom[8:14].hex(), ",".join("$%02x" % c for c in rom[8:14])))
emit("%08x  %s  dc.l $%08x" % (BASE + 14, rom[14:18].hex(), rd32(14)))
emit("%08x  %s  dc.l $%08x" % (BASE + 18, rom[18:22].hex(), rd32(18)))
emit("%08x  %s  dc.l $%08x  ; CRC-32 of bytes 0..21 (rom.c)" % (BASE + 22, rom[22:26].hex(), rd32(22)))
emit("%08x  %s  dc.l $%08x" % (BASE + 26, rom[26:30].hex(), rd32(26)))
emit("")

data_run = []
def flush_data():
    global data_run
    if not data_run: return
    k = 0
    while k < len(data_run):
        a = BASE + data_run[k]
        if k + 3 < len(data_run) and data_run[k + 3] == data_run[k] + 3 and (a & 1) == 0 and rom_ptr(rd32(data_run[k])):
            v = rd32(data_run[k])
            emit("%08x  %s  dc.l %s" % (a, rom[data_run[k]:data_run[k] + 4].hex(), sym(v) or "$%08x" % v))
            k += 4; continue
        row = data_run[k:k + 16]
        n = 1
        while n < len(row):
            if (BASE + row[n]) in labels: break
            if n + 3 < len(row) and ((BASE + row[n]) & 1) == 0 and rom_ptr(rd32(row[n])): break
            n += 1
        row = row[:n]
        bs = rom[row[0]:row[0] + len(row)]
        words = " ".join("$%04x" % struct.unpack(">H", bs[i:i + 2])[0] for i in range(0, len(bs) - 1, 2))
        tail = ("" if len(bs) % 2 == 0 else " dc.b $%02x" % bs[-1])
        asc = "".join(chr(c) if 0x20 <= c < 0x7f else "." for c in bs)
        emit("%08x  %-32s  dc.w %s%s  ; |%s|" % (a, bs.hex(), words, tail, asc))
        k += len(row)
    data_run = []

off = 0x1e
while off < SIZE:
    a = BASE + off
    lab = labels.get(a)
    if code[off] == 1:
        flush_data()
        n, mn, ops, bs = insns[a]
        if lab:
            emit("")
            callers = sorted(xref_call.get(a, ()))
            jumps = sorted(xref_jump.get(a, ()))
            ptrs = ptr_targets.get(a, ())
            note = KNOWN.get(a, (None, None))[1]
            if note: emit("; %s" % note)
            if seed_kind.get(a) == "prologue": emit("; (reached only as a C prologue: no direct caller found -- called through a computed jump or a table the scan did not recognise)")
            if callers: emit("; called from: " + ", ".join("%08x" % c for c in callers[:12]) + (" ..." if len(callers) > 12 else ""))
            if jumps: emit("; jumped to from: " + ", ".join("%08x" % c for c in jumps[:12]) + (" ..." if len(jumps) > 12 else ""))
            if ptrs: emit("; pointer table entries at: " + ", ".join("%08x" % p for p in ptrs[:8]) + (" ..." if len(ptrs) > 8 else ""))
            emit("%s:" % lab)
        ops2, notes = annotate_ops(ops)
        for m in re.finditer(r"str_([0-9a-f]{8})", ops2):
            s = strings.get(int(m.group(1), 16) - BASE)
            if s: notes.append('"%s"' % show(s)[:60])
        line = "%08x  %-16s  %-8s %s" % (a, bs.hex(), mn, ops2)
        if notes: line = "%-64s ; %s" % (line, "; ".join(notes))
        emit(line)
        off += n
    elif is_str[off] and off in strings:
        flush_data()
        s = strings[off]
        refs = sorted(xref_data.get(a, ()))
        emit("")
        if refs: emit("; referenced from: " + ", ".join("%08x" % r for r in refs[:10]) + (" ..." if len(refs) > 10 else ""))
        emit("%s:" % labels[a])
        emit("%08x  dc.b %s,0" % (a, esc(s)))
        off += len(s) + 1
    else:
        # long runs of zero (the unused tail of the ROM) collapse to one line
        if rom[off] == 0 and (a not in labels) and code[off] not in (1, 2):
            z = off
            while z < SIZE and rom[z] == 0 and code[z] not in (1, 2) and (BASE + z) not in labels: z += 1
            if z - off >= 64:
                flush_data()
                emit("%08x  dcb.b    %d,0" % (a, z - off))
                off = z
                continue
        if lab and lab.startswith("dat_"):
            flush_data()
            refs = sorted(set(xref_data.get(a, ())) | set(ptr_targets.get(a, ())))
            emit("")
            if refs: emit("; referenced from: " + ", ".join("%08x" % r for r in refs[:10]))
            emit("%s:" % lab)
        data_run.append(off)
        if len(data_run) >= 16: flush_data()
        off += 1
flush_data()

open(os.path.join(OUT, ROM_NAME + ".asm"), "w", newline="\n").write("\n".join(lines) + "\n")

# ---------------------------------------------------------------- linear sweep of unreached gaps
lin = ["; Linear-sweep disassembly of the byte ranges NOT reached by the recursive",
       "; descent (and not strings).  Speculative: much of this is data.  Use it to",
       "; look up code the descent missed (computed jumps, tables the scan did not",
       "; recognise); if a routine here is real, add its entry to KNOWN in disasm_rom.py.", ""]
off = 0x1e
while off < SIZE:
    if code[off] in (1, 2) or is_str[off]: off += 1; continue
    start = off
    while off < SIZE and code[off] not in (1, 2) and not is_str[off]: off += 1
    if off - start < 6: continue
    if not any(rom[start:off]):
        lin.append(""); lin.append("; ---- gap %08x..%08x (%d bytes) all zero ----" % (BASE + start, BASE + off - 1, off - start)); continue
    lin.append("")
    lin.append("; ---- gap %08x..%08x (%d bytes) ----" % (BASE + start, BASE + off - 1, off - start))
    p = start
    while p < off:
        ins = dis1(BASE + p)
        if ins is None or p + ins.size > off:
            lin.append("%08x  %-16s  dc.w     $%s" % (BASE + p, rom[p:p + 2].hex(), rom[p:p + 2].hex()))
            p += 2; continue
        ops2, notes = annotate_ops(ins.op_str)
        line = "%08x  %-16s  %-8s %s" % (ins.address, ins.bytes.hex(), ins.mnemonic, ops2)
        if notes: line = "%-64s ; %s" % (line, "; ".join(notes))
        lin.append(line)
        p += ins.size
open(os.path.join(OUT, "unreached-linear.asm"), "w", newline="\n").write("\n".join(lin) + "\n")

# ---------------------------------------------------------------- functions.md
subs = sorted({a for a in sub_starts if code[a - BASE] == 1} | {a for a in KNOWN if code[a - BASE] == 1})
def sub_end(a, stops):
    off = a - BASE + insns[a][0]
    while off < SIZE and code[off] == 1 and (BASE + off) not in stops:
        off += insns[BASE + off][0]
    return BASE + off
stops = set(subs)
sub_ranges = [(a, sub_end(a, stops)) for a in subs]
# code reached only by jumps (bra/jmp into a block no routine covers, e.g. the
# pre-stack continuation dispatcher at loc_01000c68) becomes a routine of its own
covered = bytearray(SIZE)
for a, e in sub_ranges:
    for k in range(a - BASE, e - BASE): covered[k] = 1
for a in sorted(loc_starts):
    off = a - BASE
    if code[off] == 1 and not covered[off]:
        stops.add(a)
        e = sub_end(a, stops)
        for k in range(off, e - BASE): covered[k] = 1
        subs.append(a); seed_kind.setdefault(a, "jump-only")
subs.sort()
sub_ranges = [(a, sub_end(a, stops)) for a in subs]
def sub_of(addr):
    for a, e in sub_ranges:
        if a <= addr < e: return a
    return None
fm = ["# Subroutines", "", "%d routines reached by the descent.  `callers` counts bsr/jsr sites; `ptr` = entries in ROM pointer tables; `seed` = how the routine was first reached (reset, ptr = pointer table, prologue = `link a6` after `rts`, known = named entry)." % len(subs), "",
      "| address | label | size | seed | callers | ptr | calls | strings referenced | devices touched | note |", "|---|---|---:|---|---:|---:|---:|---|---|---|"]
sub_devs = defaultdict(set)
sub_calls = defaultdict(set)
for a, e in sub_ranges:
    strs = []
    off = a - BASE
    while BASE + off < e:
        n, mn, ops, _ = insns[BASE + off]
        for m in re.finditer(r"\$([0-9a-f]{6,8})\b", ops):
            v = int(m.group(1), 16)
            if v - BASE in strings: strs.append(show(strings[v - BASE]).strip()[:32])
            nm = io_annot(v)
            if nm: sub_devs[a].add(nm.split(":")[0].split("+")[0].strip())
        if mn.split(".")[0] in CALLS:
            for t in re.finditer(r"\$([0-9a-f]{6,8})\b", ops):
                v = int(t.group(1), 16)
                if BASE <= v < END: sub_calls[a].add(v)
        off += n
    note = KNOWN.get(a, ("", ""))[1]
    fm.append("| %08x | %s | %d | %s | %d | %d | %d | %s | %s | %s |" % (a, labels.get(a, ""), e - a, seed_kind.get(a, ""), len(xref_call.get(a, ())), len(ptr_targets.get(a, ())), len(sub_calls[a]),
              "; ".join('"%s"' % s.replace("|", "\\|") for s in strs[:3]), ", ".join(sorted(sub_devs[a]))[:80], note.replace("|", "\\|")))
open(os.path.join(OUT, "functions.md"), "w", newline="\n").write("\n".join(fm) + "\n")

# ---------------------------------------------------------------- callgraph.md
callers_of = defaultdict(set)
for a in subs:
    for t in sub_calls[a]:
        callers_of[t].add(a)
def nm(a): return labels.get(a, "%08x" % a)
cg = ["# Call graph", "", "Direct bsr/jsr edges between routines (computed jumps and function pointers are not edges; see the `ptr` column of functions.md).", "",
      "## Call tree from reset_entry", "", "Depth-first, each routine expanded once (later occurrences are marked `(see above)`); jumps between routines (`bra`/`jmp`) are followed as well as calls.", ""]
sub_jumps = defaultdict(set)
for a, e in sub_ranges:
    off = a - BASE
    pending = None   # ROM address loaded into an address register by lea/movea just before a jmp: the pre-stack "continuation" idiom
    last_mn = ""
    while BASE + off < e:
        n, mn, ops, _ = insns[BASE + off]
        if BR.match(mn) and mn.split(".")[0] not in CALLS:   # bra/jmp and conditional branches into another routine
            for t in re.finditer(r"\$([0-9a-f]{6,8})\b", ops):
                v = int(t.group(1), 16)
                s = sub_of(v)
                if s is not None and s != a: sub_jumps[a].add(s)
            if mn.split(".")[0] in ("bra", "jmp") and pending is not None and sub_of(pending) not in (None, a): sub_jumps[a].add(sub_of(pending))
        if mn.startswith(("lea", "movea.l")):
            m = re.search(r"(?:#\$|\$)([0-9a-f]{6,8})", ops)
            v = int(m.group(1), 16) if m else None
            pending = v if (v is not None and BASE <= v < END and code[v - BASE] == 1) else None
        last_mn = mn
        off += n
    if last_mn.split(".")[0] not in STOP and e in stops:   # falls through into the next routine
        sub_jumps[a].add(e)
seen = set()
def tree(a, depth):
    tag = "" if a not in seen else " (see above)"
    cg.append("%s- `%08x` %s%s" % ("  " * depth, a, nm(a), tag))
    if a in seen or depth > 14: return
    seen.add(a)
    for t in sorted(sub_calls[a] | sub_jumps[a]):
        tree(t, depth + 1)
tree(rd32(4), 0)
cg += ["", "## Edges", "", "| routine | calls | called from |", "|---|---|---|"]
for a in subs:
    cg.append("| `%08x` %s | %s | %s |" % (a, nm(a), " ".join(nm(t) for t in sorted(sub_calls[a])), " ".join(nm(t) for t in sorted(callers_of[a]))))
open(os.path.join(OUT, "callgraph.md"), "w", newline="\n").write("\n".join(cg) + "\n")

# ---------------------------------------------------------------- strings.md
sm = ["# Strings", "", "%d NUL-terminated strings.  `refs` = code that names the address (absolute operands only; PC-relative and table references are not counted); `in routine` = the routine containing the first reference." % len(strings), "",
      "| address | refs | in routine | text |", "|---|---|---|---|"]
for off in sorted(strings):
    a = BASE + off
    refs = sorted(xref_data.get(a, ()))
    inr = sub_of(refs[0]) if refs else None
    sm.append("| %08x | %s | %s | `%s` |" % (a, " ".join("%08x" % r for r in refs[:4]), labels.get(inr, "") if inr else "", show(strings[off]).replace("|", "\\|").replace("`", "'")))
open(os.path.join(OUT, "strings.md"), "w", newline="\n").write("\n".join(sm) + "\n")

# ---------------------------------------------------------------- hardware-refs.md and memory-map.md
hw = defaultdict(list)
mem = defaultdict(list)
imm = defaultdict(list)
def op_kind(mn, ops, m):
    """abs = absolute address operand, areg = immediate loaded into an address register or stored as a pointer, imm = other immediate"""
    tail = ops[m.end():m.end() + 2]
    if tail.startswith(".l") or tail.startswith("("): return "abs"
    if ops[m.start() - 1:m.start()] == "#":
        if mn.startswith(("movea", "lea", "pea")): return "areg"
        if mn.startswith("move.l") and re.search(r",\s*(-?\$[0-9a-f]+)?\(a[0-9]\)$", ops): return "areg"   # pointer stored into a struct field
        return "imm"
    return "abs"
for a, (n, mn, ops, bs) in insns.items():
    for m in re.finditer(r"\$([0-9a-f]{7,8})\b", ops):
        v = int(m.group(1), 16)
        if BASE <= v < END: continue
        k = op_kind(mn, ops, m)
        if k == "imm" and not io_annot(v):
            imm[v].append((a, mn, ops)); continue
        if io_annot(v): hw[v].append((a, mn, ops, k))
        else: mem[v].append((a, mn, ops, k))
hm = ["# NeXT hardware registers referenced by the ROM", "",
      "Absolute device addresses appearing in ROM instructions, named from Previous's `ioMemTabTurbo.c` (Turbo table), `tmc.c` and `adb.c`.",
      "Only absolute operands are listed; register accesses through an address register (the common C idiom) are not, so also read `memory-map.md` and the listing around each base-register load.", "",
      "`kind`: abs = absolute address operand; areg = immediate loaded into an address register (movea/lea/pea) or stored as a pointer into a struct; imm = plain immediate (may be a value, not an address: e.g. TMC timing constants).", "",
      "| address | device / register | kind | uses | routines | instructions |", "|---|---|---|---:|---|---|"]
for v in sorted(hw):
    uses = sorted(hw[v])
    rs = sorted({labels.get(sub_of(a), "") for a, _, _, _ in uses if sub_of(a)})
    kinds = "/".join(sorted({k for _, _, _, k in uses}))
    hm.append("| %08x | %s | %s | %d | %s | %s |" % (v, io_annot(v), kinds, len(uses), " ".join(rs)[:120], "<br>".join("%08x %s %s" % (a, mn, o) for a, mn, o, _ in uses[:6]) + (" ..." if len(uses) > 6 else "")))
open(os.path.join(OUT, "hardware-refs.md"), "w", newline="\n").write("\n".join(hm) + "\n")

mm = ["# Absolute addresses outside ROM and device space", "",
      "Every absolute address the reached code names that is not a ROM address and not a named device register: RAM work areas, VRAM, TMC/NCC regions, cache, low memory.",
      "Regions come from Previous's `cpu/memory.c` for the Turbo configuration.", "",
      "Only address operands are listed here (absolute EA, or immediates loaded into an address register / stored as a pointer); plain immediates are in the second table.", "",
      "| address | region | kind | uses | routines | instructions |", "|---|---|---|---:|---|---|"]
for v in sorted(mem):
    uses = sorted(mem[v])
    rs = sorted({labels.get(sub_of(a), "") for a, _, _, _ in uses if sub_of(a)})
    kinds = "/".join(sorted({k for _, _, _, k in uses}))
    mm.append("| %08x | %s | %s | %d | %s | %s |" % (v, region_of(v) or "?", kinds, len(uses), " ".join(rs)[:120], "<br>".join("%08x %s %s" % (a, mn, o) for a, mn, o, _ in uses[:4]) + (" ..." if len(uses) > 4 else "")))
mm += ["", "## Plain immediates that look like addresses or 32-bit constants", "",
       "Values used with andi/ori/cmpi/move to data registers or memory: masks, test patterns, magic numbers, and timing constants.  A region name is only a hint.", "",
       "| value | region hint | uses | routines | instructions |", "|---|---|---:|---|---|"]
for v in sorted(imm):
    uses = sorted(imm[v])
    rs = sorted({labels.get(sub_of(a), "") for a, _, _ in uses if sub_of(a)})
    mm.append("| %08x | %s | %d | %s | %s |" % (v, region_of(v) or "", len(uses), " ".join(rs)[:120], "<br>".join("%08x %s %s" % (a, mn, o) for a, mn, o in uses[:3]) + (" ..." if len(uses) > 3 else "")))
open(os.path.join(OUT, "memory-map.md"), "w", newline="\n").write("\n".join(mm) + "\n")

# ---------------------------------------------------------------- summary
ncode = sum(1 for c in code if c in (1, 2))
nstr = int(sum(is_str))
last = max(i for i, b in enumerate(rom) if b)
print("code bytes %d (%.1f%%), string bytes %d, other %d, insns %d, subs %d (prologue-seeded %d), strings %d, bad stops %d, ported names %d/%d, last nonzero byte %08x" %
      (ncode, 100.0 * ncode / SIZE, nstr, SIZE - ncode - nstr, len(insns), len(subs), sum(1 for s in subs if seed_kind.get(s) == "prologue"), len(strings), len(bad_stops), len(PORTED), len(KNOWN_V66), BASE + last))
for a, (name, note, a66) in sorted(PORTED.items()):
    print("  ported %-22s v66 %08x -> v74 %08x" % (name, a66, a))
if bad_stops:
    print("bad stops:", " ".join("%08x(%s)" % (a, k) for a, k in sorted(bad_stops.items())[:20]))
