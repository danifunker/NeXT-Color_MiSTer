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
//  matter.  Their R/G/B bytes are kept in lut_r/g/b for the scan-out
//  (tc_video.sv).  Other palette entries accept writes and read back 0;
//  the overlay/cursor colours and blink masks are accepted and ignored.
//  Reset contents: a linear ramp (n * $11), so a picture is visible before
//  the ROM loads the gamma table.
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

	output    [127:0] lut_r,         // entry n in [8n+7:8n], n = pixel nibble
	output    [127:0] lut_g,
	output    [127:0] lut_b
);

reg [11:0] addr;
reg  [1:0] idx;
reg  [7:0] regs [0:15];
reg [23:0] wtt  [0:15];
reg [23:0] wtt_tmp;
reg  [7:0] pr [0:15], pg [0:15], pb [0:15];

genvar gi;
generate
for (gi = 0; gi < 16; gi = gi + 1) begin : g_lut
	assign lut_r[8*gi+7:8*gi] = pr[gi];
	assign lut_g[8*gi+7:8*gi] = pg[gi];
	assign lut_b[8*gi+7:8*gi] = pb[gi];
end
endgenerate

// the byte lane of this access: 0..3 = +0..+3
wire [1:0] lane = be[3] ? 2'd0 : be[2] ? 2'd1 : be[1] ? 2'd2 : 2'd3;
wire [7:0] wb   = (lane == 2'd0) ? wdata[31:24] : (lane == 2'd1) ? wdata[23:16] :
                  (lane == 2'd2) ? wdata[15:8]  : wdata[7:0];

// the palette entry a palette access at addr hits in the display LUT
wire       pal_disp = (addr[11:8] == 4'd0) && (addr[3:0] == 4'd0);   // entries $00..$F0
wire [3:0] pal_n    = addr[7:4];

reg  [7:0] rb;
integer i;

always @(posedge clk) begin
	ack <= 0;
	if (reset) begin
		addr <= 0;
		idx  <= 0;
		for (i = 0; i < 16; i = i + 1) begin
			regs[i] <= 8'd0;
			wtt[i]  <= 24'h000100;
			pr[i]   <= {i[3:0], i[3:0]};
			pg[i]   <= {i[3:0], i[3:0]};
			pb[i]   <= {i[3:0], i[3:0]};
		end
		wtt_tmp <= 0;
		rdata   <= 0;
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
					else rb = regs[addr[3:0]];
					if (we && addr[3:0] != 4'h0) regs[addr[3:0]] <= wb;
				end
				else if (addr[7:0] == 8'h20) rb = 8'h0A;  // revision
				idx  <= 0;
				addr <= addr + 12'd1;
			end
			4'h3: begin                              // window-type table, 3 bytes LSB first
				if (addr[7:0] < 8'h10) begin
					case (idx)
					2'd0: begin rb = wtt[addr[3:0]][7:0];   if (we) wtt_tmp <= {16'd0, wb}; end
					2'd1: begin rb = wtt[addr[3:0]][15:8];  if (we) wtt_tmp[15:8] <= wb; end
					default: begin
						rb = wtt[addr[3:0]][23:16];
						if (we) wtt[addr[3:0]] <= {wb, wtt_tmp[15:0]};
					end
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
				case (idx)
				2'd0: begin rb = pr[pal_n]; if (we) pr[pal_n] <= wb; end
				2'd1: begin rb = pg[pal_n]; if (we) pg[pal_n] <= wb; end
				default: begin rb = pb[pal_n]; if (we) pb[pal_n] <= wb; end
				endcase
			end
			if (idx == 2'd2) begin idx <= 0; addr <= addr + 12'd1; end
			else idx <= idx + 2'd1;
		end
		endcase
		rdata <= {rb, rb, rb, rb};
	end
end

endmodule
