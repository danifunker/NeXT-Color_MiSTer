//============================================================================
//  tc_bt463 -- Brooktree Bt463 RAMDAC host interface at $0201C000..3.
//
//  Previous r1851 ramdac.c is the model; rom-dissassembly/hardware-summary.md
//  section 4.2 ("HS") is what the Rev 3.3 v74 ROM does with it.
//
//  Byte registers: +0 address low, +1 address high (4 bits), +2 control
//  data (cursor colour $01xx, registers $02xx, window-type table $03xx),
//  +3 palette data (R, G, B bytes per entry).  Address auto-increment
//  follows ramdac.c bt463_autoinc (3 bytes per entry) and
//  bt463_autoinc_reg (1 byte per register); writing the address resets the
//  byte index.  ID register $0200 reads $2A, revision $0220 reads $0A.
//
//  What is stored (area): the 16 command/mask registers, the 16-entry
//  window-type table, and of the 528-entry colour palette only the
//  entries the display uses.  The ROM programs window type $000100 for all
//  16 types (planes field = 8, true colour, start 0) and read masks $F0
//  (HS 4.2), so each 4-bit channel value n of a pixel addresses entry
//  n << 4 of that channel's palette, and only entries $00,$10,...,$F0
//  matter.  Other palette entries accept writes and read back 0; the
//  overlay/cursor colours and blink masks are accepted and ignored.
//
//  Storage is block RAM, not flip-flops (area): the registers and the
//  host's copy of the 16 x 3 display entries in one 64 x 8 M10K, the
//  window-type table in a 16 x 24 M10K, both read continuously at the
//  current address (it changes only on an access, and accesses are
//  several clocks apart), so an access finds its byte already read.  Every
//  display-palette write also goes out on pal_we/pal_n/pal_d to the
//  scan-out's own palette RAMs (tc_vram.sv), which the pixel nibbles read
//  in the video clock domain.
//  Contents at power-up: registers 0, window types $000100, palette a
//  linear ramp (n * $11); the video palette RAMs start at 0.  A machine
//  reset keeps them (block RAM has no reset): the ROM reprograms every
//  register, window type and palette entry in dac_init_bt463 (HS 4.2)
//  before it enables video, and video is black until then.
//
//  Device port contract (tc_machine): stb 1-cycle, ack 1-cycle one clock
//  later; be[3] = byte at +0.  One byte lane per access (the ROM uses
//  move.b); with several lanes set, the lowest address wins.
//============================================================================

module tc_bt463
(
	input             clk,
	input             reset,

	input             stb,
	input             we,
	input       [3:0] be,
	input      [31:0] wdata,
	output reg [31:0] rdata,
	output reg        ack,

	// display palette writes, for the scan-out's palette RAMs (clk domain)
	output reg  [2:0] pal_we,        // one-hot: R, G, B
	output reg  [3:0] pal_n,         // entry n << 4
	output reg  [7:0] pal_d
);

reg [11:0] addr;
reg  [1:0] idx;
reg [15:0] wtt_tmp;

// the byte lane of this access: 0..3 = +0..+3
wire [1:0] lane = be[3] ? 2'd0 : be[2] ? 2'd1 : be[1] ? 2'd2 : 2'd3;
wire [7:0] wb   = (lane == 2'd0) ? wdata[31:24] : (lane == 2'd1) ? wdata[23:16] :
                  (lane == 2'd2) ? wdata[15:8]  : wdata[7:0];

// the palette entry a palette access at addr hits in the display LUT
wire       pal_disp = (addr[11:8] == 4'd0) && (addr[3:0] == 4'd0);   // entries $00..$F0
wire [3:0] pal_idx  = addr[7:4];

//----------------------------------------------------------------------------
// storage: cmem = {section, n}: section 0 registers $0200..$020F, 1..3 the
// palette R, G, B bytes of entry n << 4; wmem = window types $0300..$030F
//----------------------------------------------------------------------------
(* ramstyle = "M10K, no_rw_check" *) reg  [7:0] cmem [0:63];
(* ramstyle = "M10K, no_rw_check" *) reg [23:0] wmem [0:15];
reg  [7:0] cq;
reg [23:0] wq;

integer i;
initial begin
	for (i = 0; i < 16; i = i + 1) begin
		cmem[i]      = 8'd0;
		cmem[16 + i] = {i[3:0], i[3:0]};
		cmem[32 + i] = {i[3:0], i[3:0]};
		cmem[48 + i] = {i[3:0], i[3:0]};
		wmem[i]      = 24'h000100;
	end
end

// what the next access at this address and byte index reads: a register
// when the address is in $02xx, else the palette byte idx of entry addr[7:4]
wire [5:0] c_raddr = (addr[11:8] == 4'h2) ? {2'd0, addr[3:0]} : {idx + 2'd1, pal_idx};

// this access's write, if any
wire       w_reg = stb && we && lane == 2'd2 && addr[11:8] == 4'h2 && addr[7:4] == 4'h0 &&
                   addr[3:0] != 4'h0;
wire       w_pal = stb && we && lane == 2'd3 && pal_disp && idx != 2'd3;
wire       w_wtt = stb && we && lane == 2'd2 && addr[11:8] == 4'h3 && addr[7:4] == 4'h0 &&
                   idx == 2'd2;
wire [5:0] c_waddr = w_pal ? {idx + 2'd1, pal_idx} : {2'd0, addr[3:0]};

always @(posedge clk) begin
	if (w_reg || w_pal) cmem[c_waddr] <= wb;
	if (w_wtt) wmem[addr[3:0]] <= {wb, wtt_tmp};
	cq <= cmem[c_raddr];
	wq <= wmem[addr[3:0]];
end

//----------------------------------------------------------------------------
// the host port
//----------------------------------------------------------------------------
reg  [7:0] rb;

always @(posedge clk) begin
	ack    <= 0;
	pal_we <= 3'd0;
	if (reset) begin
		addr    <= 0;
		idx     <= 0;
		wtt_tmp <= 0;
		rdata   <= 0;
		pal_n   <= 0;
		pal_d   <= 0;
	end
	else if (stb) begin
		ack <= 1;
		rb   = 8'd0;
		case (lane)
		2'd0: begin                                  // address low
			rb = addr[7:0];
			if (we) addr[7:0] <= wb;
			idx <= 0;
		end
		2'd1: begin                                  // address high
			rb = {4'd0, addr[11:8]};
			if (we) addr[11:8] <= wb[3:0];
			idx <= 0;
		end
		2'd2: begin                                  // control data
			case (addr[11:8])
			4'h1: begin                              // cursor colours: accept, 3-byte step
				rb = 8'd0;
				if (idx == 2'd2) begin idx <= 0; addr <= addr + 12'd1; end
				else idx <= idx + 2'd1;
			end
			4'h2: begin                              // registers (bt463_read/write_reg)
				if (addr[7:0] < 8'h10) begin
					if (addr[3:0] == 4'h0) rb = 8'h2A;     // ID
					else rb = cq;
				end
				else if (addr[7:0] == 8'h20) rb = 8'h0A;  // revision
				idx  <= 0;
				addr <= addr + 12'd1;
			end
			4'h3: begin                              // window-type table, 3 bytes LSB first
				if (addr[7:0] < 8'h10) begin
					case (idx)
					2'd0: begin rb = wq[7:0];   if (we) wtt_tmp <= {8'd0, wb}; end
					2'd1: begin rb = wq[15:8];  if (we) wtt_tmp[15:8] <= wb; end
					default: rb = wq[23:16];                // written above (w_wtt)
					endcase
				end
				if (idx == 2'd2) begin idx <= 0; addr <= addr + 12'd1; end
				else idx <= idx + 2'd1;
			end
			default: ;
			endcase
		end
		default: begin                               // palette data R, G, B
			if (pal_disp) begin
				rb = cq;
				if (we) begin
					pal_we <= 3'b001 << idx;
					pal_n  <= pal_idx;
					pal_d  <= wb;
				end
			end
			if (idx == 2'd2) begin idx <= 0; addr <= addr + 12'd1; end
			else idx <= idx + 2'd1;
		end
		endcase
		rdata <= {rb, rb, rb, rb};
	end
end

endmodule
