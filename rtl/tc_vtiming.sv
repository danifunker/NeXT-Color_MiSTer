//============================================================================
//  tc_vtiming -- the TMC's video timing generator (NeXTstation Turbo Color).
//
//  The TMC counts the horizontal in 4-pixel units and the vertical in lines.
//  Register layout (Previous tmc.c, "Horizontal and Vertical Configuration
//  Registers"; hardware-summary section 2.5):
//
//      [31:25] front porch   [24:19] sync   [18:12] back porch   [11:0] display
//
//  $02200088 is the horizontal register, $0220008C the vertical one.  The
//  ROM never writes them on a Turbo Color that presents SCR2 byte 2 bit 4 =
//  1 (tmc_reset_config skips the 832x624 write), so the power-on value must
//  already be 1120x832: Previous tmc.c tmc_video_reg_reset() uses
//      H = $31048118  (fp 24, sync 32, bp 72, display 280 -> 1632 px/line)
//      V = $10430340  (fp  8, sync  8, bp 48, display 832 ->  896 lines)
//  which at the 100 MHz pixel clock is 61.3 kHz / 68.4 Hz.
//
//  Line order: display, front porch, sync, back porch; same for the frame.
//  Everything runs on clk_vid with CE_PIXEL = 1.  The register values come
//  from clk_sys; they are quasi-static, so they are re-sampled through two
//  flops and only taken at the end of a frame, which keeps a mid-frame write
//  from tearing the picture.  A zero display or sync field is ignored.
//
//  The line and frame thresholds (sync start/end, total, the line_pre point)
//  are computed from the re-sampled registers in their own pipeline stage
//  and loaded with the geometry at the frame boundary, so the per-pixel
//  logic only compares the counters with registered constants (timing: the
//  three cascaded adders used to sit between the counters and their
//  reload).
//============================================================================

module tc_vtiming
(
	input             clk_vid,
	input             reset,        // clk_vid domain

	input      [31:0] hreg,         // clk_sys domain, quasi-static
	input      [31:0] vreg,

	output reg        hs,           // active high
	output reg        vs,           // active high
	output reg        hblank,
	output reg        vblank,
	output reg [11:0] x,            // pixel within the visible line (valid while !hblank)
	output reg [11:0] y,            // visible line (valid while !vblank)
	output reg        line_pre,     // one clock, PRE_LINE pixels before a visible line starts
	output reg        frame_start,  // one clock at the first pixel of the frame
	output reg        vbl_start,    // one clock when the vertical blank begins
	output     [13:0] h_active,     // current geometry, in pixels / lines
	output     [11:0] v_active
);

localparam [31:0] H_RESET = 32'h31048118;
localparam [31:0] V_RESET = 32'h10430340;
// how far ahead of a visible line line_pre fires (lets the scan-out start
// its fetch for the NEXT line during the horizontal blank)
localparam [13:0] PRE_LINE = 14'd256;

reg [31:0] hreg_m, hreg_s, vreg_m, vreg_s;
always @(posedge clk_vid) begin
	hreg_m <= hreg; hreg_s <= hreg_m;
	vreg_m <= vreg; vreg_s <= vreg_m;
end

// thresholds of a geometry register pair (display, sync start, sync end,
// last pixel / line of the frame, the line_pre pixel)
function automatic [69:0] h_thr;         // {disp, sy0, sy1, tot-1, tot-PRE_LINE}
	input [31:0] r;
	reg [13:0] d, s0, s1, t;
	begin
		d  = {r[11:0], 2'b00};
		s0 = d  + {5'd0, r[31:25], 2'b00};
		s1 = s0 + {6'd0, r[24:19], 2'b00};
		t  = s1 + {5'd0, r[18:12], 2'b00};
		h_thr = {d, s0, s1, t - 14'd1, t - PRE_LINE};
	end
endfunction
function automatic [47:0] v_thr;         // {disp, sy0, sy1, tot-1}
	input [31:0] r;
	reg [11:0] d, s0, s1, t;
	begin
		d  = r[11:0];
		s0 = d  + {5'd0, r[31:25]};
		s1 = s0 + {6'd0, r[24:19]};
		t  = s1 + {5'd0, r[18:12]};
		v_thr = {d, s0, s1, t - 12'd1};
	end
endfunction

// the next geometry's thresholds (pipeline stage after the re-sampling)
reg [69:0] h_nx;
reg [47:0] v_nx;
reg        h_nx_ok, v_nx_ok;
always @(posedge clk_vid) begin
	h_nx    <= h_thr(hreg_s);
	v_nx    <= v_thr(vreg_s);
	h_nx_ok <= (hreg_s[11:0] != 0 && hreg_s[24:19] != 0);
	v_nx_ok <= (vreg_s[11:0] != 0 && vreg_s[24:19] != 0);
end

// the geometry in use this frame
reg [13:0] h_disp, h_sy0, h_sy1, h_last, h_pre;
reg [11:0] v_disp, v_sy0, v_sy1, v_last;

assign h_active = h_disp;
assign v_active = v_disp;

reg [13:0] hc;
reg [11:0] vc;

wire h_end = (hc >= h_last);             // hc + 1 >= total
wire v_end = (vc >= v_last);

// the line that line_pre announces: the next visible line
wire [11:0] vc_next = v_end ? 12'd0 : vc + 12'd1;

always @(posedge clk_vid) begin
	line_pre    <= 0;
	frame_start <= 0;
	vbl_start   <= 0;
	if (reset) begin
		{h_disp, h_sy0, h_sy1, h_last, h_pre} <= h_thr(H_RESET);
		{v_disp, v_sy0, v_sy1, v_last}        <= v_thr(V_RESET);
		hc <= 0; vc <= 0;
		hs <= 0; vs <= 0; hblank <= 0; vblank <= 0; x <= 0; y <= 0;
	end
	else begin
		if (h_end) begin
			hc <= 0;
			if (v_end) begin
				vc <= 0;
				// frame boundary: take new geometry
				if (h_nx_ok) {h_disp, h_sy0, h_sy1, h_last, h_pre} <= h_nx;
				if (v_nx_ok) {v_disp, v_sy0, v_sy1, v_last}        <= v_nx;
			end
			else vc <= vc + 12'd1;
		end
		else hc <= hc + 14'd1;

		// registered outputs describe the pixel at (hc, vc) of this clock
		hblank <= (hc >= h_disp);
		vblank <= (vc >= v_disp);
		hs     <= (hc >= h_sy0) && (hc < h_sy1);
		vs     <= (vc >= v_sy0) && (vc < v_sy1);
		x      <= hc[11:0];
		y      <= vc;
		frame_start <= (hc == 0) && (vc == 0);
		vbl_start   <= (hc == 0) && (vc == v_disp);
		// announce the next visible line PRE_LINE pixels before its start
		if (hc == h_pre && vc_next < v_disp) line_pre <= 1;
	end
end

endmodule
