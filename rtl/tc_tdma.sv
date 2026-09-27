//============================================================================
//  tc_tdma -- the Turbo PC chip's DMA channels ("TDMA", ISP on the Turbo
//  board): every register of Previous r1851 ioMemTabTurbo.c:37-106, the
//  Turbo CSR command/status semantics of dma.c TDMA_CSR_Read/Write, and the
//  data engine of the SCSI channel (the only channel that moves data yet).
//
//  "HS n" = rom-dissassembly/hardware-summary.md section n; "dma.c:n" /
//  "ioMemTabTurbo.c:n" = scratch/resources/previous-r1851-src.
//
//  Origin: the channel half of NeXT_MiSTer rtl/next/next_scsi.sv (commit
//  11c4185): d_csr, d_next/limit/start/stop, dma_hit_limit (chain on
//  SUPDATE), dma_bus_exception, the CSR/pointer/init register writes and
//  the memory master.  The 16-byte channel buffer stays with its only user,
//  tc_scsi (the ESP side), exactly as next_scsi.sv had it; this module owns
//  the channel's registers, its window arithmetic and the memory port.
//
//  Device port (tc_machine contract): stb 1-cycle, ack 2 cycles later with
//  rdata; addr = longword address in the 128 KB device page, bit 12
//  ignored (every entry of ioMemTabTurbo.c:38-106 has mask $0001EFFF).
//  Only decoded registers are strobed by the machine; anything else in the
//  decode reads 0 and ignores writes.
//
//  Registers (o = offset in the device page, ch = channel code o[8:4]):
//    CSR  $02000010 SCSI, $040 sound out, $080 sound in, $090 printer,
//         $0D0 DSP, $110 Ethernet TX, $150 Ethernet RX
//         (ioMemTabTurbo.c:38-44, TDMA_CSR_Read/Write dma.c:1112-1178)
//         read (long): bit 24 ENABLE, 25 SUPDATE, 27 COMPLETE, 28 BUSEXC
//           (dma.c:77-80); everything else reads 0.
//         write (long, command bits 23:16, dma.c:82-88, 1105-1107):
//           bit 18 DEV2M      direction, taken from every write (dma.c:1158)
//           bit 20 RESET      clears COMPLETE|SUPDATE|ENABLE (dma.c:1160)
//           bit 23 BUFRESET   empties the channel buffer (dma.c:1163, 152-169)
//           bit 17 SETSUPDATE (dma.c:1166)
//           bit 16 SETENABLE  (dma.c:1169); SCSI: a Next not on a longword
//                             or a Limit not on a 16-byte burst boundary is
//                             refused with COMPLETE|BUSEXC (Previous
//                             abort()s in dma_esp_*_memory, dma.c:395/505)
//           bit 19 CLRCOMPLETE clears COMPLETE (dma.c:1172) -- CONDITIONAL
//                             here: only for a running channel or together
//                             with SETENABLE, and a completion generated on
//                             the same clock wins (next_scsi lesson, NeXT_MiSTer
//                             docs/SCSI_DMA.md; NetBSD nextdmareg.h calls it
//                             "clear complete conditional", dma.c:86 too).
//                             RESET still clears a simultaneous completion.
//           bit 21 SETCOMPLETE, bit 22 FLUSH: Previous only logs them
//                             (dma.c:1133-1155); no action here either (the
//                             SCSI flush is the ESP DMA control bit, tc_scsi).
//         BUSEXC is only cleared by the machine reset (DMA_Reset dma.c:1226).
//    Next/Limit/Start/Stop  $020040x0/4/8/C for the seven channels
//         (ioMemTabTurbo.c:47-97, DMA_Next_Read..DMA_Stop_Write dma.c:297-343)
//    saved limit $02004050, read-only: Ethernet RX saved_limit
//         (ioMemTabTurbo.c:59, TDMA_Saved_Limit_Read dma.c:1180); writes ignored
//    plain registers $02004100-$0200410C, $02004140-$0200414C: read back
//         what was written (ioMemTabTurbo.c:80-83, 90-93); the ROM writes
//         $0200411C (HS 8.1) which is the TX Stop register, also fine.
//    init $02004210/40/80/90/D0, $02004310/50: write = Next (and, for
//         SCSI, empty the channel buffer at offset Next & $F); read = Next
//         (ioMemTabTurbo.c:100-106, DMA_Init_Read/Write dma.c:345-356)
//
//  SCSI channel engine (the client is tc_scsi, port sc_*):
//    * one longword per request at Next (sc_req level until sc_ack /
//      sc_err); Next advances by 4, clamped at Limit (next_scsi);
//      tc_scsi moves its 16-byte buffer as four such words (a burst).
//    * sc_eval = dma_interrupt() (dma.c:361-381): if the channel is enabled
//      and Next has reached Limit: COMPLETE; with SUPDATE the channel
//      continues with Start/Stop (2-descriptor chaining, HS 7), else it
//      stops.  An eval requested while a word is in flight waits for it.
//    * a memory bus error (m_err) stops the channel with COMPLETE|BUSEXC
//      (dma.c:445-449); Next does not advance.
//    * INT_SCSI_DMA (interrupt status bit 26, sysReg.h) = COMPLETE: the
//      level Previous sets in dma_interrupt and releases on a CSR write
//      that leaves COMPLETE clear (dma.c:1175).
//    * Next is plain state: dma_stop's read after RESET (HS 7) returns where
//      the transfer stopped.
//
//  Ethernet channels (the client is tc_enet, ports et_* / er_*), Previous's
//  "channel does not use DMA buffering" path (dma.c:795-900):
//    * TX: one longword per request at Next; et_n = the bytes of it before
//      ENADDR(Limit) (Limit with the EOP/BOP flag bits 31:30 masked,
//      dma.c:796-798); Next advances by et_n, so it ends exactly on the
//      frame's end.  et_done = dma_enet_interrupt(TX) (dma.c:800-818).
//    * RX: er_n bytes per request written at Next (big-endian lanes), Next
//      advances by er_n.  er_eof (dma.c:850-868): saved limit = Next, saved
//      nibble = Next & $F; without SUPDATE, Next is rounded down to its burst
//      and, if still below Limit, moved to the next burst; then
//      dma_enet_interrupt(RX).  er_full: dma_enet_interrupt(RX) only.
//    * dma_enet_interrupt: COMPLETE; with SUPDATE continue with Start/Stop
//      and clear SUPDATE, else clear ENABLE.  INT_EN_RX_DMA / INT_EN_TX_DMA
//      = COMPLETE.
//    * the saved limit $02004050 reads the RX channel's (dma.c:1180).
//  The memory master serves one request at a time; SCSI first, then RX,
//  then TX, then sound out.
//
//  Sound out channel (the client is tc_kms, port so_*), the sound box
//  side of Previous kms.c kms_sndout_request / dma.c dma_sndout_read_memory
//  and dma_sndout_intr (dma.c:694-727):
//    * one longword (one 16-bit stereo frame {L,R}) per request at Next;
//      Next and Limit are used on longword boundaries (Previous masks a
//      misaligned pair with ~3, dma.c:701-706).  so_avail = ENABLE and
//      Next < Limit: the sound box has a buffer to play.
//    * the word that brings Next to Limit completes the channel
//      (dma_interrupt, dma.c:361-381): COMPLETE; with SUPDATE continue with
//      Start/Stop, else clear ENABLE.  Previous raises it when the sound box
//      asks for the next buffer, one buffer later; the mono core (NeXT_MiSTer
//      next_kms_snd.sv, on hardware) raises it at the last fetch, as here.
//    * a word whose client dropped so_req while it was in flight (the KMS
//      flushed its queue), or whose channel was RESET meanwhile, is
//      dropped and Next stays (the mono core's dma_cancelled).
//    * INT_SND_OUT_DMA (bit 23) = COMPLETE; a bus error stops the channel
//      with COMPLETE|BUSEXC (dma.c:714-718).
//
//  DSP channel (the client is tc_dsp, port dd_*), dma.c dma_dsp_write_memory
//  / dma_dsp_read_memory / dma_dsp_ready (dma.c:975-1043): one byte per
//  request at Next (the DSP host port's DMA moves bytes, dsp.c:139-172);
//  dd_avail = ENABLE and Next < Limit.  The byte that brings Next to Limit
//  pulses dd_blkend (DSP_SetIRQB) and completes the channel (dma_interrupt:
//  COMPLETE, SUPDATE chain or ENABLE off).  A withdrawn request or a RESET
//  drops the byte in flight.  INT_DSP_DMA (bit 20) = COMPLETE.
//
//  Other channels (sound in, printer): register model only.  Their
//  CSR status bits are flip-flops (same command semantics); their
//  Next/Limit/Start/Stop and the plain registers live in one 32-word RAM (no
//  reset: block RAM / MLAB).  HOOK: to give a channel an engine, move its
//  four pointers out of that RAM into flip-flops like the SCSI and Ethernet
//  sets below, add a client port and an owner code for the memory master.
//  Their COMPLETE bits already drive the interrupt outputs.
//============================================================================

module tc_tdma
(
	input             clk,
	input             reset,

	// device port (tc_machine contract)
	input             stb,
	input             we,
	input      [16:2] addr,          // longword address in the device page
	input       [3:0] be,            // big-endian: be[3] = data[31:24]
	input      [31:0] wdata,
	output reg [31:0] rdata,
	output reg        ack,

	// memory master (DRAM through the machine's service FSM)
	output reg        m_req,         // level until m_ack / m_err
	output reg        m_we,
	output reg [31:2] m_addr,        // physical longword address
	output reg  [3:0] m_be,
	output reg [31:0] m_wdata,
	input             m_ack,         // 1-cycle; m_rdata valid with it
	input      [31:0] m_rdata,
	input             m_err,         // 1-cycle: bus error -> BUSEXC

	// SCSI channel client port (tc_scsi ch_*)
	input             sc_req,        // level: move one longword at Next
	input             sc_we,         // 1 = device to memory
	input      [31:0] sc_wdata,
	input             sc_eval,       // pulse: dma_interrupt()
	output reg        sc_ack,        // pulse: word done, Next already advanced
	output reg [31:0] sc_rdata,      // with sc_ack (memory to device)
	output reg        sc_err,        // pulse: bus error, channel stopped
	output            sc_enable,     // CSR ENABLE
	output            sc_dev2m,      // direction of the last CSR write
	output            sc_room,       // Next < Limit
	output            sc_at_limit,   // Next == Limit
	output            sc_bufreset,   // pulse (same clock as the write): empty the buffer
	output      [3:0] sc_bufofs,     // with sc_bufreset: first fill position

	// Ethernet transmit channel client port (tc_enet et_*): memory -> chip
	input             et_req,        // level: read the longword at Next
	output reg        et_ack,        // pulse: et_rdata valid, Next already advanced
	output reg [31:0] et_rdata,
	output reg  [2:0] et_n,          // with et_ack: valid bytes from et_rdata[31:24] (1..4)
	output reg        et_err,        // pulse: bus error, channel stopped
	output            et_enable,     // CSR ENABLE
	output            et_room,       // Next < ENADDR(Limit)
	input             et_done,       // pulse: frame read, dma_enet_interrupt()

	// Ethernet receive channel client port (tc_enet er_*): chip -> memory
	input             er_req,        // level: write er_n bytes of er_wdata at Next
	input      [31:0] er_wdata,
	input       [2:0] er_n,          // 1..4, from er_wdata[31:24]
	output reg        er_ack,        // pulse: written, Next advanced
	output reg        er_err,        // pulse: bus error, channel stopped
	output            er_enable,     // CSR ENABLE
	output            er_room,       // Next < Limit
	input             er_eof,        // pulse: the frame is in memory (saved limit, interrupt)
	input             er_full,       // pulse: Next reached Limit inside a frame (interrupt)
	output reg  [3:0] er_nibble,     // the saved nibble ($02006007, ethernet.c:600)

	// sound out channel client port (tc_kms so_*): memory -> sound box
	input             so_req,        // level: read the longword at Next
	output reg        so_ack,        // pulse: so_rdata valid, Next already advanced
	output reg [31:0] so_rdata,      // one frame {L[15:0], R[15:0]}
	output            so_avail,      // ENABLE and Next < Limit

	// DSP channel client port (tc_dsp dd_*): one byte per request
	input             dd_req,        // level: move one byte at Next
	input             dd_we,         // 1 = device to memory
	input       [7:0] dd_wdata,
	output reg        dd_ack,        // pulse: done, Next already advanced
	output reg  [7:0] dd_rdata,      // with dd_ack (memory to device)
	output            dd_avail,      // ENABLE and Next < Limit
	output reg        dd_blkend,     // pulse with dd_ack: Next reached Limit

	// interrupt levels (interrupt status bits, Previous sysReg.h)
	output            int_scsi_dma,     // 26
	output            int_snd_out_dma,  // 23
	output            int_snd_in_dma,   // 22
	output            int_printer_dma,  // 24
	output            int_dsp_dma,      // 20
	output            int_en_tx_dma,    // 28
	output            int_en_rx_dma     // 27
);

// channel numbers
localparam [2:0] C_SCSI = 3'd0, C_SNDOUT = 3'd1, C_SNDIN = 3'd2, C_PRINTER = 3'd3,
                 C_DSP  = 3'd4, C_ENTX   = 3'd5, C_ENRX  = 3'd6;

//----------------------------------------------------------------------------
// address decode (ioMemTabTurbo.c:38-106, mask $1EFFF)
//----------------------------------------------------------------------------
wire [16:2] o    = {addr[16:13], 1'b0, addr[11:2]};
wire  [4:0] code = o[8:4];
wire  [1:0] rsel = o[3:2];            // 0 Next, 1 Limit, 2 Start, 3 Stop

reg  [2:0] ch;
reg        ch_ok;
always @* begin
	ch_ok = 1'b1;
	case (code)
	5'h01:   ch = C_SCSI;
	5'h04:   ch = C_SNDOUT;
	5'h08:   ch = C_SNDIN;
	5'h09:   ch = C_PRINTER;
	5'h0D:   ch = C_DSP;
	5'h11:   ch = C_ENTX;
	5'h15:   ch = C_ENRX;
	default: begin ch = C_SCSI; ch_ok = 1'b0; end
	endcase
end

wire pg_csr  = (o[16:9] == 8'h00);                      // $02000000-$020001FF
wire pg_ptr  = (o[16:9] == 8'h20);                      // $02004000-$020041FF
wire pg_init = (o[16:9] == 8'h21);                      // $02004200-$020043FF
wire is_csr   = pg_csr  && ch_ok && rsel == 2'd0;
wire is_ptr   = pg_ptr  && ch_ok;
wire is_init  = pg_init && ch_ok && rsel == 2'd0;
wire is_slim  = pg_ptr  && code == 5'h05 && rsel == 2'd0;   // $02004050
wire is_plain = pg_ptr  && (code == 5'h10 || code == 5'h14);

// bit 12 is not decoded (mask $1EFFF)
/* verilator lint_off UNUSEDSIGNAL */
wire unused_a12 = addr[12];
/* verilator lint_on UNUSEDSIGNAL */

// the CSR command byte (long bits 23:16); a write without that lane has none
wire [7:0] wcmd = be[2] ? wdata[23:16] : 8'h00;
// SETCOMPLETE (bit 21) and FLUSH (bit 22): logged, not acted on, by Previous
/* verilator lint_off UNUSEDSIGNAL */
wire unused_cmd = &{1'b0, wcmd[6:5]};
/* verilator lint_on UNUSEDSIGNAL */

function automatic [31:0] merge;
	input [31:0] old;
	input [31:0] d;
	input  [3:0] b;
	begin
		merge = {b[3] ? d[31:24] : old[31:24], b[2] ? d[23:16] : old[23:16],
		         b[1] ? d[15:8]  : old[15:8],  b[0] ? d[7:0]   : old[7:0]};
	end
endfunction

//----------------------------------------------------------------------------
// channel state
//----------------------------------------------------------------------------
reg  [7:0] c_en, c_sup, c_cmp, c_bex, c_dir;    // CSR bits 24, 25, 27, 28; DEV2M (bit 7: no channel)
reg [31:0] s_next, s_limit, s_start, s_stop;     // the SCSI channel's pointers
reg [31:0] t_next, t_limit, t_start, t_stop;     // Ethernet TX
reg [31:0] r_next, r_limit, r_start, r_stop;     // Ethernet RX
reg [31:0] o_next, o_limit, o_start, o_stop;     // sound out
reg [31:0] p_next, p_limit, p_start, p_stop;     // DSP
reg [31:0] en_rx_saved_limit;                    // dma.c:852, read at $02004050

wire [31:0] t_end = {2'b00, t_limit[29:0]};      // ENADDR(limit), dma.c:798

assign sc_enable   = c_en[C_SCSI];
assign sc_dev2m    = c_dir[C_SCSI];
// One subtraction per channel gives every comparison its engine needs
// (area): borrow = Next > Limit, zero = Next == Limit, and the high bits
// say whether a longword still fits.
wire [32:0] s_d = {1'b0, s_limit} - {1'b0, s_next};
wire        s_eq = (s_d[31:0] == 32'd0);
wire        s_lt = !s_d[32] && !s_eq;                     // Next < Limit
wire        s_clamp = s_d[32] || (s_d[31:2] == 30'd0);    // Next + 4 > Limit
wire [32:0] t_d = {1'b0, t_end} - {1'b0, t_next};

assign sc_room     = s_lt;
assign sc_at_limit = s_eq;
assign et_enable   = c_en[C_ENTX];
assign et_room     = !t_d[32] && (t_d[31:0] != 32'd0);
assign er_enable   = c_en[C_ENRX];
assign er_room     = r_next < r_limit;
// sound out, in longwords (dma.c:701-706): words left = Limit - Next
wire [30:0] o_d    = {1'b0, o_limit[31:2]} - {1'b0, o_next[31:2]};
wire        o_lt   = !o_d[30] && (o_d[29:0] != 30'd0);     // Next < Limit
wire        o_last = (o_d[29:0] == 30'd1);                  // this word reaches Limit
assign so_avail    = c_en[C_SNDOUT] && o_lt;
// DSP, in bytes (dma_dsp_ready): Next < Limit, and the byte that reaches it
wire [32:0] p_d    = {1'b0, p_limit} - {1'b0, p_next};
wire        p_lt   = !p_d[32] && (p_d[31:0] != 32'd0);
wire        p_last = (p_d[31:0] == 32'd1);
assign dd_avail    = c_en[C_DSP] && p_lt;

assign int_scsi_dma    = c_cmp[C_SCSI];
assign int_snd_out_dma = c_cmp[C_SNDOUT];
assign int_snd_in_dma  = c_cmp[C_SNDIN];
assign int_printer_dma = c_cmp[C_PRINTER];
assign int_dsp_dma     = c_cmp[C_DSP];
assign int_en_tx_dma   = c_cmp[C_ENTX];
assign int_en_rx_dma   = c_cmp[C_ENRX];

// BUFRESET on the SCSI CSR, or a write to the SCSI init register
// (dma_initialize_buffer, dma.c:152-161).  Combinational so that tc_scsi
// empties its buffer on the same clock as the register write.
wire [31:0] init_val = merge(s_next, wdata, be);
assign sc_bufreset = stb && we && ch == C_SCSI &&
                     ((is_csr && wcmd[7]) || is_init);
assign sc_bufofs   = is_init ? init_val[3:0] : 4'd0;

//----------------------------------------------------------------------------
// register RAM for the channels without an engine (byte lanes, no reset)
//   idx {ch, rsel} for ch 1..6 (4..27); plain $041x0 -> 0..3, $041x4 -> 28..31
//----------------------------------------------------------------------------
reg  [7:0] ram3 [0:31];
reg  [7:0] ram2 [0:31];
reg  [7:0] ram1 [0:31];
reg  [7:0] ram0 [0:31];
reg [31:0] ram_q;
integer ri;
initial for (ri = 0; ri < 32; ri = ri + 1) begin
	ram3[ri] = 8'h00; ram2[ri] = 8'h00; ram1[ri] = 8'h00; ram0[ri] = 8'h00;
end

wire [4:0] ram_idx = is_plain ? {code[2] ? 3'd7 : 3'd0, rsel} :
                     {ch, is_init ? 2'd0 : rsel};
wire       ch_ff   = (ch == C_SCSI) || (ch == C_ENTX) || (ch == C_ENRX) ||
                     (ch == C_SNDOUT) || (ch == C_DSP);       // pointers in flip-flops
wire       ram_hit = ((is_ptr || is_init) && !ch_ff) || is_plain;
wire       ram_we  = stb && we && ram_hit;

always @(posedge clk) begin
	if (stb) ram_q <= {ram3[ram_idx], ram2[ram_idx], ram1[ram_idx], ram0[ram_idx]};
	if (ram_we && be[3]) ram3[ram_idx] <= wdata[31:24];
	if (ram_we && be[2]) ram2[ram_idx] <= wdata[23:16];
	if (ram_we && be[1]) ram1[ram_idx] <= wdata[15:8];
	if (ram_we && be[0]) ram0[ram_idx] <= wdata[7:0];
end

//----------------------------------------------------------------------------
// register read: flip-flop sources sampled with stb, the RAM word one clock
// later; ack two clocks after stb.
//----------------------------------------------------------------------------
reg        p_stb, p_ram;
reg [31:0] p_ff;

wire [31:0] s_ptr_q = (rsel == 2'd0) ? s_next  : (rsel == 2'd1) ? s_limit :
                      (rsel == 2'd2) ? s_start : s_stop;
wire [31:0] t_ptr_q = (rsel == 2'd0) ? t_next  : (rsel == 2'd1) ? t_limit :
                      (rsel == 2'd2) ? t_start : t_stop;
wire [31:0] r_ptr_q = (rsel == 2'd0) ? r_next  : (rsel == 2'd1) ? r_limit :
                      (rsel == 2'd2) ? r_start : r_stop;
wire [31:0] o_ptr_q = (rsel == 2'd0) ? o_next  : (rsel == 2'd1) ? o_limit :
                      (rsel == 2'd2) ? o_start : o_stop;
wire [31:0] p_ptr_q = (rsel == 2'd0) ? p_next  : (rsel == 2'd1) ? p_limit :
                      (rsel == 2'd2) ? p_start : p_stop;
wire [31:0] ff_ptr_q = (ch == C_ENTX) ? t_ptr_q : (ch == C_ENRX) ? r_ptr_q :
                       (ch == C_SNDOUT) ? o_ptr_q : (ch == C_DSP) ? p_ptr_q : s_ptr_q;
wire [31:0] ff_next  = (ch == C_ENTX) ? t_next  : (ch == C_ENRX) ? r_next  :
                       (ch == C_SNDOUT) ? o_next : (ch == C_DSP) ? p_next : s_next;

always @(posedge clk) begin
	if (reset) begin
		p_stb <= 1'b0;
		ack   <= 1'b0;
	end
	else begin
		p_stb <= stb;
		ack   <= p_stb;
	end
	if (stb) begin
		p_ram <= ram_hit;
		p_ff  <= is_csr  ? {3'b000, c_bex[ch], c_cmp[ch], 1'b0, c_sup[ch], c_en[ch], 24'd0} :
		         is_slim ? en_rx_saved_limit :
		         (is_ptr  && ch_ff) ? ff_ptr_q :
		         (is_init && ch_ff) ? ff_next : 32'd0;
	end
	if (p_stb) rdata <= p_ram ? ram_q : p_ff;
end

//----------------------------------------------------------------------------
// channel engines and register writes
//----------------------------------------------------------------------------
localparam [2:0] O_SCSI = 3'd0, O_ENRX = 3'd1, O_ENTX = 3'd2, O_SNDO = 3'd3, O_DSP = 3'd4;
reg  [2:0] m_owner;     // whose longword is on the memory master
reg  [2:0] m_n;         // its byte count (Ethernet)
reg eval_pend;          // an eval arrived while a SCSI word was in flight
reg orphan;             // the SCSI / sound client dropped its request before the word finished
reg o_cancel;           // the sound out channel was RESET while its word was in flight
reg p_cancel;           // the DSP channel was RESET while its byte was in flight

// the TX frame's bytes left in the longword at Next (Next stays on a
// longword until the frame's last one)
wire  [2:0] t_n    = (t_d[31:2] != 30'd0) ? 3'd4 : t_d[2:0];   // only used while Next < end

// dma.c:855-859: without SUPDATE, Next goes back to the start of its burst
// and, while that is below Limit, on to the next burst
wire [31:0] r_burst = {r_next[31:4], 4'd0};
wire [31:0] r_after = (r_burst < r_limit) ? r_burst + 32'd16 : r_burst;

always @(posedge clk) begin : engine
	reg [7:0] ev;   // a completion or fault on this clock, per channel (CLRCOMPLETE loses)
	ev = 8'd0;
	sc_ack <= 1'b0;
	sc_err <= 1'b0;
	et_ack <= 1'b0;
	et_err <= 1'b0;
	er_ack <= 1'b0;
	er_err <= 1'b0;
	so_ack <= 1'b0;
	dd_ack <= 1'b0;
	dd_blkend <= 1'b0;
	if (reset) begin
		// DMA_Reset (dma.c:1226): every CSR cleared
		c_en <= 8'd0; c_sup <= 8'd0; c_cmp <= 8'd0; c_bex <= 8'd0; c_dir <= 8'd0;
		s_next <= 32'd0; s_limit <= 32'd0; s_start <= 32'd0; s_stop <= 32'd0;
		t_next <= 32'd0; t_limit <= 32'd0; t_start <= 32'd0; t_stop <= 32'd0;
		r_next <= 32'd0; r_limit <= 32'd0; r_start <= 32'd0; r_stop <= 32'd0;
		o_next <= 32'd0; o_limit <= 32'd0; o_start <= 32'd0; o_stop <= 32'd0;
		p_next <= 32'd0; p_limit <= 32'd0; p_start <= 32'd0; p_stop <= 32'd0;
		en_rx_saved_limit <= 32'd0;
		er_nibble <= 4'd0;
		m_req <= 1'b0; m_we <= 1'b0; m_addr <= 30'd0; m_be <= 4'h0; m_wdata <= 32'd0;
		m_owner <= O_SCSI; m_n <= 3'd0;
		sc_rdata <= 32'd0;
		et_rdata <= 32'd0; et_n <= 3'd0;
		so_rdata <= 32'd0;
		dd_rdata <= 8'd0;
		eval_pend <= 1'b0;
		orphan <= 1'b0;
		o_cancel <= 1'b0;
		p_cancel <= 1'b0;
	end
	else begin
		//------------------------------------------------------------
		// the memory master: one longword for one client at a time
		// (SCSI first, then Ethernet RX, then TX, then sound out, then DSP)
		//------------------------------------------------------------
		if (m_req) begin
			if ((m_owner == O_SCSI && !sc_req) || (m_owner == O_SNDO && !so_req) ||
			    (m_owner == O_DSP && !dd_req))
				orphan <= 1'b1;
			if (m_err || m_ack) begin
				m_req    <= 1'b0;
				orphan   <= 1'b0;
				o_cancel <= 1'b0;
				p_cancel <= 1'b0;
			end
			if (m_err) begin
				// the channel stops with COMPLETE|BUSEXC (dma.c:445-449,
				// 845-848, 886-889)
				case (m_owner)
				O_SCSI: begin
					sc_err <= sc_req && !orphan;
					c_en[C_SCSI] <= 1'b0; c_cmp[C_SCSI] <= 1'b1; c_bex[C_SCSI] <= 1'b1;
					ev[C_SCSI] = 1'b1;
				end
				O_ENRX: begin
					er_err <= 1'b1;
					c_en[C_ENRX] <= 1'b0; c_cmp[C_ENRX] <= 1'b1; c_bex[C_ENRX] <= 1'b1;
					ev[C_ENRX] = 1'b1;
				end
				O_ENTX: begin
					et_err <= 1'b1;
					c_en[C_ENTX] <= 1'b0; c_cmp[C_ENTX] <= 1'b1; c_bex[C_ENTX] <= 1'b1;
					ev[C_ENTX] = 1'b1;
				end
				O_SNDO: begin
					// sound out: dma.c:714-718 (the client just sees no data)
					c_en[C_SNDOUT] <= 1'b0; c_cmp[C_SNDOUT] <= 1'b1; c_bex[C_SNDOUT] <= 1'b1;
					ev[C_SNDOUT] = 1'b1;
				end
				default: begin
					// DSP: dma.c:992-996, 1021-1025
					c_en[C_DSP] <= 1'b0; c_cmp[C_DSP] <= 1'b1; c_bex[C_DSP] <= 1'b1;
					ev[C_DSP] = 1'b1;
				end
				endcase
			end
			else if (m_ack) begin
				case (m_owner)
				O_SCSI: begin
					sc_ack <= sc_req && !orphan;
					sc_rdata <= m_rdata;
					// a malformed limit must not carry Next past it (next_scsi)
					s_next <= s_clamp ? s_limit : s_next + 32'd4;
				end
				O_ENRX: begin
					er_ack <= 1'b1;
					r_next <= r_next + {29'd0, m_n};
				end
				O_ENTX: begin
					et_ack   <= 1'b1;
					et_rdata <= m_rdata;
					et_n     <= m_n;
					t_next   <= t_next + {29'd0, m_n};
				end
				O_DSP: if (dd_req && !orphan && !p_cancel) begin
					// DSP: one byte, then DSP_SetIRQB + dma_interrupt() on
					// the last (dma.c:998-1001, 1027-1030)
					dd_ack   <= 1'b1;
					dd_rdata <= m_rdata[31 - 8 * p_next[1:0] -: 8];
					p_next   <= p_next + 32'd1;
					if (p_last) begin
						dd_blkend <= 1'b1;
						ev[C_DSP] = 1'b1;
						c_cmp[C_DSP] <= 1'b1;
						if (c_sup[C_DSP]) begin
							c_sup[C_DSP] <= 1'b0;
							p_next  <= p_start;
							p_limit <= p_stop;
						end
						else c_en[C_DSP] <= 1'b0;
					end
				end
				default: if (so_req && !orphan && !o_cancel) begin
					// sound out: one frame, then dma_interrupt() on the last
					so_ack   <= 1'b1;
					so_rdata <= m_rdata;
					o_next   <= {o_next[31:2] + 30'd1, 2'b00};
					if (o_last) begin
						ev[C_SNDOUT] = 1'b1;
						c_cmp[C_SNDOUT] <= 1'b1;
						if (c_sup[C_SNDOUT]) begin
							c_sup[C_SNDOUT] <= 1'b0;       // 1st done
							o_next  <= o_start;
							o_limit <= o_stop;
						end
						else c_en[C_SNDOUT] <= 1'b0;       // all done
					end
				end
				endcase
			end
		end
		else if (sc_req && !sc_ack && !sc_err) begin
			m_req   <= 1'b1;
			m_owner <= O_SCSI;
			m_we    <= sc_we;
			m_addr  <= s_next[31:2];
			m_be    <= 4'hF;
			m_wdata <= sc_wdata;
		end
		else if (er_req && !er_ack && !er_err) begin
			m_req   <= 1'b1;
			m_owner <= O_ENRX;
			m_we    <= 1'b1;
			m_addr  <= r_next[31:2];
			m_be    <= 4'b1111 << (3'd4 - er_n);     // er_n bytes from lane 3 (byte +0)
			m_wdata <= er_wdata;
			m_n     <= er_n;
		end
		else if (et_req && !et_ack && !et_err) begin
			m_req   <= 1'b1;
			m_owner <= O_ENTX;
			m_we    <= 1'b0;
			m_addr  <= t_next[31:2];
			m_be    <= 4'hF;
			m_wdata <= 32'd0;
			m_n     <= t_n;
		end
		else if (so_req && !so_ack && so_avail) begin
			m_req   <= 1'b1;
			m_owner <= O_SNDO;
			m_we    <= 1'b0;
			m_addr  <= o_next[31:2];
			m_be    <= 4'hF;
			m_wdata <= 32'd0;
		end
		else if (dd_req && !dd_ack && dd_avail) begin
			m_req   <= 1'b1;
			m_owner <= O_DSP;
			m_we    <= dd_we;
			m_addr  <= p_next[31:2];
			m_be    <= 4'b1000 >> p_next[1:0];         // big-endian byte lane
			m_wdata <= {4{dd_wdata}};
		end

		//------------------------------------------------------------
		// SCSI: dma_interrupt() (dma.c:361-381).  Its callers return early
		// on a disabled channel (dma.c:391, 455, 501), hence the ENABLE test.
		//------------------------------------------------------------
		if ((sc_eval || eval_pend) && m_req && m_owner == O_SCSI)
			eval_pend <= 1'b1;
		else if (sc_eval || eval_pend) begin
			eval_pend <= 1'b0;
			if (c_en[C_SCSI] && !s_lt) begin
				ev[C_SCSI] = 1'b1;
				c_cmp[C_SCSI] <= 1'b1;
				if (c_sup[C_SCSI]) begin
					c_sup[C_SCSI] <= 1'b0;             // 1st done
					if (s_start[1:0] != 2'd0 || s_stop[3:0] != 4'd0) begin
						c_en[C_SCSI]  <= 1'b0;         // misaligned window: dma.c:395
						c_bex[C_SCSI] <= 1'b1;
					end
					else begin
						s_next  <= s_start;
						s_limit <= s_stop;
					end
				end
				else c_en[C_SCSI] <= 1'b0;             // all done
			end
		end

		//------------------------------------------------------------
		// Ethernet: dma_enet_interrupt() (dma.c:800-818).  tc_enet raises
		// et_done / er_eof / er_full only with no word of its own in flight.
		//------------------------------------------------------------
		if (et_done) begin
			ev[C_ENTX] = 1'b1;
			c_cmp[C_ENTX] <= 1'b1;
			if (c_sup[C_ENTX]) begin
				c_sup[C_ENTX] <= 1'b0;
				t_next  <= t_start;
				t_limit <= t_stop;
			end
			else c_en[C_ENTX] <= 1'b0;
		end
		if (er_eof || er_full) begin
			ev[C_ENRX] = 1'b1;
			c_cmp[C_ENRX] <= 1'b1;
			if (er_eof) begin
				en_rx_saved_limit <= r_next;           // dma.c:852
				er_nibble <= r_next[3:0];               // dma.c:854
			end
			if (c_sup[C_ENRX]) begin
				c_sup[C_ENRX] <= 1'b0;
				r_next  <= r_start;
				r_limit <= r_stop;
			end
			else begin
				c_en[C_ENRX] <= 1'b0;
				if (er_eof) r_next <= r_after;
			end
		end

		//------------------------------------------------------------
		// register writes (after the engines: RESET wins over a completion)
		//------------------------------------------------------------
		if (stb && we) begin
			if (is_csr) begin
				// TDMA_CSR_Write (dma.c:1120-1178)
				c_dir[ch] <= wcmd[2];
				if (wcmd[4]) begin                      // RESET
					c_en[ch]  <= 1'b0;
					c_sup[ch] <= 1'b0;
					c_cmp[ch] <= 1'b0;
					// a sound word in flight is dropped (the mono core's
					// dma_cancelled); Next stays where the reset found it
					if (ch == C_SNDOUT && m_req && m_owner == O_SNDO && !m_ack && !m_err)
						o_cancel <= 1'b1;
					if (ch == C_DSP && m_req && m_owner == O_DSP && !m_ack && !m_err)
						p_cancel <= 1'b1;
				end
				if (wcmd[1]) c_sup[ch] <= 1'b1;         // SETSUPDATE
				if (wcmd[0]) begin                      // SETENABLE
					if (ch == C_SCSI && (s_next[1:0] != 2'd0 || s_limit[3:0] != 4'd0)) begin
						c_en[C_SCSI]  <= 1'b0;
						c_cmp[C_SCSI] <= 1'b1;
						c_bex[C_SCSI] <= 1'b1;
						ev[C_SCSI] = 1'b1;
					end
					else c_en[ch] <= 1'b1;
				end
				// CLRCOMPLETE, conditional (see the header)
				if (wcmd[3] && (c_en[ch] || wcmd[0]) && !ev[ch])
					c_cmp[ch] <= 1'b0;
			end
			if (is_ptr && ch == C_SCSI) begin
				case (rsel)
				2'd0: s_next  <= merge(s_next,  wdata, be);
				2'd1: s_limit <= merge(s_limit, wdata, be);
				2'd2: s_start <= merge(s_start, wdata, be);
				default: s_stop <= merge(s_stop, wdata, be);
				endcase
			end
			if (is_ptr && ch == C_ENTX) begin
				case (rsel)
				2'd0: t_next  <= merge(t_next,  wdata, be);
				2'd1: t_limit <= merge(t_limit, wdata, be);
				2'd2: t_start <= merge(t_start, wdata, be);
				default: t_stop <= merge(t_stop, wdata, be);
				endcase
			end
			if (is_ptr && ch == C_ENRX) begin
				case (rsel)
				2'd0: r_next  <= merge(r_next,  wdata, be);
				2'd1: r_limit <= merge(r_limit, wdata, be);
				2'd2: r_start <= merge(r_start, wdata, be);
				default: r_stop <= merge(r_stop, wdata, be);
				endcase
			end
			if (is_ptr && ch == C_SNDOUT) begin
				case (rsel)
				2'd0: o_next  <= merge(o_next,  wdata, be);
				2'd1: o_limit <= merge(o_limit, wdata, be);
				2'd2: o_start <= merge(o_start, wdata, be);
				default: o_stop <= merge(o_stop, wdata, be);
				endcase
			end
			if (is_init && ch == C_SCSI) s_next <= init_val;
			if (is_init && ch == C_ENTX) t_next <= merge(t_next, wdata, be);
			if (is_init && ch == C_ENRX) r_next <= merge(r_next, wdata, be);
			if (is_init && ch == C_SNDOUT) o_next <= merge(o_next, wdata, be);
			if (is_ptr && ch == C_DSP) begin
				case (rsel)
				2'd0: p_next  <= merge(p_next,  wdata, be);
				2'd1: p_limit <= merge(p_limit, wdata, be);
				2'd2: p_start <= merge(p_start, wdata, be);
				default: p_stop <= merge(p_stop, wdata, be);
				endcase
			end
			if (is_init && ch == C_DSP) p_next <= merge(p_next, wdata, be);
		end
	end
end

endmodule
