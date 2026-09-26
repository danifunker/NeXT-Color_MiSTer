//============================================================================
//  tc_vram -- the Turbo Color's 2 MB VRAM in DDR3, and the video scan-out.
//
//  VRAM ($0C000000, 2 MB, hardware-summary 3.1/3.4/3.5) is far too big for
//  M10K, so it lives in the HPS DDR3 at byte address $30000000 (the scaler
//  uses $20000000..$217FFFFF).  Three clock domains:
//
//  clk_sys (33 MHz)  the machine's beat port (memsel VRAM): one longword at
//                    a time, level req, 1-cycle ack.
//  clk_ram (99 MHz)  DDRAM_CLK.  Exactly 3x clk_sys from the same PLL, phase
//                    aligned (rtl/pll), so the CPU request/done crossing is a
//                    plain timed multi-rate path (toggles, no synchronisers).
//                    Serves CPU beats and the scan-out's line fetches, one
//                    DDR3 transaction at a time, alternating when both wait.
//  clk_vid (100 MHz) the pixel clock (rtl/pll_vid.v): timing (tc_vtiming),
//                    line buffer read, Bt463 lookup, VGA out.
//
//  CPU side (after NeXT_MiSTer rtl/next/next_ddram.sv): a read miss fetches
//  the aligned 16-byte line (2-beat burst) and keeps it; later reads from
//  that line are served without DDR3; a write is one beat with byte
//  enables and updates the kept line.  Byte order: the machine is big
//  endian, DDR3 little endian: bytes are swapped within each 32-bit half,
//  the even longword in DOUT[31:0].
//
//  Scan-out: 16 bpp RRRRGGGGBBBBxxxx, 2 pixels per long, left pixel in the
//  high word, rowbytes = 2 x visible width (2240 at 1120), frame at VRAM
//  offset 0 (hardware-summary 3.5, vid_init_color_1120x832 $0100b9e6).
//  A two-line buffer (dual-clock M10K, 2 x 512 x 64): the fetch engine
//  keeps it filled up to two lines ahead of the last line displayed; lines
//  0 and 1 are fetched during the vertical blank.  Each 4-bit channel
//  value n picks Bt463 palette entry n<<4 of that channel (tc_bt463.sv),
//  so the ROM's gamma/brightness palette is honoured.  Video disabled
//  (TMC $02200080 ENABLE clear) outputs black.
//============================================================================

module tc_vram
(
	input             clk_sys,
	input             clk_ram,
	input             clk_vid,
	input             reset,          // clk_sys domain (machine reset)
	input             reset_vid,      // clk_vid domain

	// CPU beats (clk_sys)
	input             req,
	input             we,
	input      [20:2] addr,
	input       [3:0] be,
	input      [31:0] wdata,
	output reg        ack,
	output reg [31:0] rdata,

	// video control (clk_sys, quasi-static)
	input      [31:0] hreg,
	input      [31:0] vreg,
	input             video_enable,
	input       [2:0] pal_we,         // clk_sys: Bt463 display-palette write (R, G, B one-hot)
	input       [3:0] pal_n,
	input       [7:0] pal_d,
	output reg        vbl_pulse,      // clk_sys: one pulse per frame (vertical blank start)

	// video out (clk_vid)
	output reg  [7:0] vga_r,
	output reg  [7:0] vga_g,
	output reg  [7:0] vga_b,
	output reg        vga_hs,         // active high
	output reg        vga_vs,         // active high
	output reg        vga_de,

	// DDR3 (clk_ram)
	input             DDRAM_BUSY,
	output reg  [7:0] DDRAM_BURSTCNT,
	output reg [28:0] DDRAM_ADDR,
	input      [63:0] DDRAM_DOUT,
	input             DDRAM_DOUT_READY,
	output reg        DDRAM_RD,
	output reg [63:0] DDRAM_DIN,
	output reg  [7:0] DDRAM_BE,
	output reg        DDRAM_WE
);

localparam [28:0] VRAM_BASE = 29'h0600_0000;     // byte $30000000 / 8
localparam  [7:0] FETCH_BURST = 8'd40;           // words per scan-out burst (280 = 7 x 40)

function [31:0] bswap;
	input [31:0] x;
	bswap = {x[7:0], x[15:8], x[23:16], x[31:24]};
endfunction

//============================================================================
// CPU request, clk_sys side
//============================================================================
reg        c_req_t = 0;        // toggles once per request
reg        c_we;
reg [20:2] c_addr;
reg  [3:0] c_be;
reg [31:0] c_wdata;
reg        c_busy;
reg        r_done_t = 0;       // clk_ram: toggles when a request completes
reg [31:0] r_rdata;
reg        c_done_seen = 0;

always @(posedge clk_sys) begin
	ack <= 0;
	if (reset) begin
		c_busy <= 0;
		c_done_seen <= r_done_t;
	end
	else begin
		if (!c_busy) c_done_seen <= r_done_t;
		if (req && !c_busy && !ack) begin
			c_we    <= we;
			c_addr  <= addr;
			c_be    <= be;
			c_wdata <= wdata;
			c_req_t <= ~c_req_t;
			c_busy  <= 1;
		end
		if (c_busy && (r_done_t != c_done_seen)) begin
			c_done_seen <= r_done_t;
			c_busy <= 0;
			ack    <= 1;
			rdata  <= r_rdata;
		end
	end
end

//============================================================================
// clk_vid: timing, line bookkeeping for the fetch engine
//============================================================================
reg [31:0] hreg_v, vreg_v;          // re-sampled in tc_vtiming
reg        ven_meta, ven_v;
always @(posedge clk_vid) begin
	ven_meta <= video_enable;
	ven_v    <= ven_meta;
end

wire        t_hs, t_vs, t_hbl, t_vbl, t_frame, t_vbl_start, t_line_pre;
wire [11:0] t_x, t_y;
wire [13:0] t_hact;
wire [11:0] t_vact;
tc_vtiming vtiming (
	.clk_vid(clk_vid),
	.reset(reset_vid),
	.hreg(hreg),
	.vreg(vreg),
	.hs(t_hs),
	.vs(t_vs),
	.hblank(t_hbl),
	.vblank(t_vbl),
	.x(t_x),
	.y(t_y),
	.line_pre(t_line_pre),
	.frame_start(t_frame),
	.vbl_start(t_vbl_start),
	.h_active(t_hact),
	.v_active(t_vact)
);

// last completely displayed line: set at the end of every visible line,
// reset to "none" (all ones) when the vertical blank starts.  Published to
// clk_ram with a toggle (it changes once per line, so the value is stable
// long before the toggle is seen).
reg [11:0] v_done_line = 12'hFFF;
reg        v_done_t = 0;
reg        hbl_d = 1;
reg        v_frame_t = 0;
reg [11:0] v_lines;                 // visible lines, captured with the line
reg [13:0] v_width;                 // visible pixels
always @(posedge clk_vid) begin
	hbl_d <= t_hbl;
	if (reset_vid) begin
		v_done_line <= 12'hFFF;
		v_done_t    <= 0;
	end
	else if (t_vbl_start) begin
		v_done_line <= 12'hFFF;
		v_done_t    <= ~v_done_t;
		v_frame_t   <= ~v_frame_t;
		v_lines     <= t_vact;
		v_width     <= t_hact;
	end
	else if (t_hbl && !hbl_d && !t_vbl) begin     // end of a visible line
		v_done_line <= t_y;
		v_done_t    <= ~v_done_t;
	end
end

// frame interrupt to clk_sys (tc_tmc): the vertical-blank toggle
reg [2:0] vbl_sync = 0;
always @(posedge clk_sys) begin
	vbl_sync  <= {vbl_sync[1:0], v_frame_t};
	vbl_pulse <= vbl_sync[2] ^ vbl_sync[1];
end

//============================================================================
// clk_ram: DDR3 engine (no reset: power-up values; the machine reset does
// not need to reach it, it only ever finishes the transaction in flight)
//============================================================================
// CPU request (multi-rate path from clk_sys, see header)
reg        r_req_seen = 0;
// line bookkeeping from clk_vid
reg  [2:0] r_done_sync = 0;
reg [11:0] r_done_line = 12'hFFF;
reg [11:0] r_lines = 12'd832;
reg [13:0] r_width = 14'd1120;
reg        r_newframe = 0;
always @(posedge clk_ram) begin
	r_done_sync <= {r_done_sync[1:0], v_done_t};
	r_newframe  <= 0;
	if (r_done_sync[2] != r_done_sync[1]) begin
		r_done_line <= v_done_line;
		r_lines     <= v_lines;
		r_width     <= v_width;
		r_newframe  <= (v_done_line == 12'hFFF);
	end
end

// the kept CPU line
reg [127:0] line;
reg  [20:4] line_tag;
reg         line_valid = 0;

// fetch engine: fetches whole lines, in bursts, into the line buffer half
// line[0].  Allowed up to two lines past the last one displayed (none at
// the start of a frame: lines 0 and 1; 12'hFFF + 2 wraps to 1).
reg  [11:0] f_line = 0;             // line being / next to be fetched
reg   [8:0] f_word = 0;             // next word of that line
reg  [20:3] f_base = 0;             // word address of line f_line
reg         f_active = 0;           // a line is partly fetched
reg         f_restart = 0;          // a new frame began: back to line 0
reg   [9:0] f_ptr = 0;              // line buffer write pointer
wire  [8:0] f_words  = r_width[10:2];
wire [11:0] f_limit  = r_done_line + 12'd2;
wire  [8:0] f_remain = f_words - f_word;
wire  [7:0] f_burst  = (f_remain > {1'b0, FETCH_BURST}) ? FETCH_BURST : f_remain[7:0];
wire        f_want   = !f_restart && (f_line < r_lines) && (f_line <= f_limit) && (f_words != 0);

// line buffer write port
reg         lb_we = 0;
reg   [9:0] lb_waddr = 0;
reg  [63:0] lb_wdata;

localparam E_IDLE = 2'd0, E_CPU_RD = 2'd1, E_CPU_WR = 2'd2, E_FETCH = 2'd3;
reg  [1:0] e_state = E_IDLE;
reg  [7:0] e_beats = 0;             // beats left in the burst
reg        e_turn = 0;              // 1: the CPU goes next when both wait
reg        e_beat = 0;              // CPU line fill: second beat
reg  [1:0] e_want = 0;

wire cpu_pend = (c_req_t != r_req_seen);

initial begin
	DDRAM_RD = 0;
	DDRAM_WE = 0;
	DDRAM_BURSTCNT = 8'd1;
end

always @(posedge clk_ram) begin
	lb_we <= 0;
	if (!DDRAM_BUSY) begin
		DDRAM_RD <= 0;
		DDRAM_WE <= 0;
	end
	if (r_newframe) f_restart <= 1;

	case (e_state)
	E_IDLE: if (!DDRAM_RD && !DDRAM_WE) begin
		if (f_restart) begin
			// between bursts: drop whatever line was in progress
			f_restart <= 0;
			f_active  <= 0;
			f_line    <= 0;
			f_word    <= 0;
			f_base    <= 0;
		end
		else if (cpu_pend && (e_turn || !f_want)) begin
			r_req_seen <= c_req_t;
			e_turn     <= 0;
			if (c_we) begin
				DDRAM_ADDR     <= VRAM_BASE + {10'd0, c_addr[20:3]};
				DDRAM_BURSTCNT <= 8'd1;
				DDRAM_DIN      <= {2{bswap(c_wdata)}};
				DDRAM_BE       <= c_addr[2] ? {c_be[0], c_be[1], c_be[2], c_be[3], 4'b0000}
				                            : {4'b0000, c_be[0], c_be[1], c_be[2], c_be[3]};
				DDRAM_WE       <= 1;
				if (line_valid && line_tag == c_addr[20:4]) begin
					case (c_addr[3:2])
					2'd0: begin
						if (c_be[3]) line[127:120] <= c_wdata[31:24];
						if (c_be[2]) line[119:112] <= c_wdata[23:16];
						if (c_be[1]) line[111:104] <= c_wdata[15:8];
						if (c_be[0]) line[103:96]  <= c_wdata[7:0];
					end
					2'd1: begin
						if (c_be[3]) line[95:88] <= c_wdata[31:24];
						if (c_be[2]) line[87:80] <= c_wdata[23:16];
						if (c_be[1]) line[79:72] <= c_wdata[15:8];
						if (c_be[0]) line[71:64] <= c_wdata[7:0];
					end
					2'd2: begin
						if (c_be[3]) line[63:56] <= c_wdata[31:24];
						if (c_be[2]) line[55:48] <= c_wdata[23:16];
						if (c_be[1]) line[47:40] <= c_wdata[15:8];
						if (c_be[0]) line[39:32] <= c_wdata[7:0];
					end
					default: begin
						if (c_be[3]) line[31:24] <= c_wdata[31:24];
						if (c_be[2]) line[23:16] <= c_wdata[23:16];
						if (c_be[1]) line[15:8]  <= c_wdata[15:8];
						if (c_be[0]) line[7:0]   <= c_wdata[7:0];
					end
					endcase
				end
				e_state <= E_CPU_WR;
			end
			else if (line_valid && line_tag == c_addr[20:4]) begin
				r_rdata  <= (c_addr[3:2] == 2'd0) ? line[127:96] :
				            (c_addr[3:2] == 2'd1) ? line[95:64]  :
				            (c_addr[3:2] == 2'd2) ? line[63:32]  : line[31:0];
				r_done_t <= ~r_done_t;
			end
			else begin
				DDRAM_ADDR     <= VRAM_BASE + {10'd0, c_addr[20:4], 1'b0};
				DDRAM_BURSTCNT <= 8'd2;
				DDRAM_BE       <= 8'hFF;
				DDRAM_RD       <= 1;
				line_valid     <= 0;
				e_beat         <= 0;
				e_want         <= c_addr[3:2];
				e_state        <= E_CPU_RD;
			end
		end
		else if (f_want) begin
			// one burst of the line
			e_turn         <= 1;
			f_active       <= 1;
			DDRAM_ADDR     <= VRAM_BASE + {10'd0, f_base} + {20'd0, f_word};
			DDRAM_BURSTCNT <= f_burst;
			DDRAM_BE       <= 8'hFF;
			DDRAM_RD       <= 1;
			e_beats        <= f_burst;
			f_ptr          <= {f_line[0], f_word};
			e_state        <= E_FETCH;
		end
	end
	E_CPU_WR: if (!DDRAM_BUSY) begin
		r_done_t <= ~r_done_t;
		e_state  <= E_IDLE;
	end
	E_CPU_RD: if (DDRAM_DOUT_READY) begin
		if (!e_beat) begin
			line[127:64] <= {bswap(DDRAM_DOUT[31:0]), bswap(DDRAM_DOUT[63:32])};
			e_beat <= 1;
			if (!e_want[1]) r_rdata <= e_want[0] ? bswap(DDRAM_DOUT[63:32]) : bswap(DDRAM_DOUT[31:0]);
		end
		else begin
			line[63:0] <= {bswap(DDRAM_DOUT[31:0]), bswap(DDRAM_DOUT[63:32])};
			if (e_want[1]) r_rdata <= e_want[0] ? bswap(DDRAM_DOUT[63:32]) : bswap(DDRAM_DOUT[31:0]);
			line_tag   <= c_addr[20:4];
			line_valid <= 1;
			r_done_t   <= ~r_done_t;
			e_state    <= E_IDLE;
		end
	end
	E_FETCH: if (DDRAM_DOUT_READY) begin
		lb_we    <= 1;
		lb_waddr <= f_ptr;
		lb_wdata <= DDRAM_DOUT;
		f_ptr    <= f_ptr + 10'd1;
		f_word   <= f_word + 9'd1;
		e_beats  <= e_beats - 8'd1;
		if (e_beats == 8'd1) begin
			e_state <= E_IDLE;
			if (f_word + 9'd1 >= f_words) begin
				// the line is complete; the next one starts rowbytes/8 = width/4 words on
				f_active <= 0;
				f_word   <= 0;
				f_line   <= f_line + 12'd1;
				f_base   <= f_base + {6'd0, r_width[13:2]};
			end
		end
	end
	endcase
end

//============================================================================
// the line buffer: 2 lines x 512 words x 64 bits, write clk_ram, read clk_vid
//============================================================================
wire [63:0] lb_q;
reg   [9:0] lb_raddr;

tc_dpram_dc #(.AW(10), .DW(64)) linebuf (
	.wclk(clk_ram), .we(lb_we), .waddr(lb_waddr), .wdata(lb_wdata),
	.rclk(clk_vid), .raddr(lb_raddr), .q(lb_q)
);

//============================================================================
// clk_vid: pixel pipeline
//   c0: timing outputs (t_*)       -> line buffer address
//   c1: RAM address registered     -> q valid at c2
//   c2: pixel select: the channel nibbles address the palette RAMs
//   c3: palette bytes valid        -> VGA registers at c4
//
// The Bt463 display palette (16 entries per channel, tc_bt463.sv) lives in
// three dual-clock M10K RAMs, written from clk_sys by the Bt463's palette
// writes and read here by the pixel's R, G and B nibbles: no copy of the
// table in flip-flops and no multi-bit clock crossing.
//============================================================================
wire [7:0] pal_r, pal_g, pal_b;
wire [3:0] pr, pg, pb;             // the pixel's channel nibbles (c2)

tc_dpram_dc #(.AW(4), .DW(8)) pal_ram_r (
	.wclk(clk_sys), .we(pal_we[0]), .waddr(pal_n), .wdata(pal_d),
	.rclk(clk_vid), .raddr(pr), .q(pal_r));
tc_dpram_dc #(.AW(4), .DW(8)) pal_ram_g (
	.wclk(clk_sys), .we(pal_we[1]), .waddr(pal_n), .wdata(pal_d),
	.rclk(clk_vid), .raddr(pg), .q(pal_g));
tc_dpram_dc #(.AW(4), .DW(8)) pal_ram_b (
	.wclk(clk_sys), .we(pal_we[2]), .waddr(pal_n), .wdata(pal_d),
	.rclk(clk_vid), .raddr(pb), .q(pal_b));

reg  [1:0] px1, px2;
reg  [2:0] hs_p, vs_p, de_p;
always @(posedge clk_vid) begin
	// c0 -> c1
	lb_raddr <= {t_y[0], t_x[10:2]};
	px1      <= t_x[1:0];
	hs_p[0]  <= t_hs;
	vs_p[0]  <= t_vs;
	de_p[0]  <= !(t_hbl | t_vbl);
	// c1 -> c2
	px2      <= px1;
	hs_p[1]  <= hs_p[0];
	vs_p[1]  <= vs_p[0];
	de_p[1]  <= de_p[0];
	// c2 -> c3 (the palette RAMs register the nibbles)
	hs_p[2]  <= hs_p[1];
	vs_p[2]  <= vs_p[1];
	de_p[2]  <= de_p[1];
end

// the pixel: bytes 2p (high) and 2p+1 of the little-endian DDR word
wire [15:0] pix = (px2 == 2'd0) ? {lb_q[7:0],   lb_q[15:8]}  :
                  (px2 == 2'd1) ? {lb_q[23:16], lb_q[31:24]} :
                  (px2 == 2'd2) ? {lb_q[39:32], lb_q[47:40]} :
                                  {lb_q[55:48], lb_q[63:56]};
assign pr = pix[15:12];
assign pg = pix[11:8];
assign pb = pix[7:4];

always @(posedge clk_vid) begin
	vga_hs <= hs_p[2];
	vga_vs <= vs_p[2];
	vga_de <= de_p[2];
	if (de_p[2] && ven_v) begin
		vga_r <= pal_r;
		vga_g <= pal_g;
		vga_b <= pal_b;
	end
	else {vga_r, vga_g, vga_b} <= 24'd0;
end

endmodule
