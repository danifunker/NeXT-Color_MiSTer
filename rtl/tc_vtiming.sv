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

reg [31:0] hcur, vcur;                 // geometry in use this frame

wire [13:0] h_disp = {hcur[11:0], 2'b00};
wire [13:0] h_sy0  = h_disp + {5'd0, hcur[31:25], 2'b00};
wire [13:0] h_sy1  = h_sy0  + {6'd0, hcur[24:19], 2'b00};
wire [13:0] h_tot  = h_sy1  + {5'd0, hcur[18:12], 2'b00};
wire [11:0] v_disp = vcur[11:0];
wire [11:0] v_sy0  = v_disp + {5'd0, vcur[31:25]};
wire [11:0] v_sy1  = v_sy0  + {6'd0, vcur[24:19]};
wire [11:0] v_tot  = v_sy1  + {5'd0, vcur[18:12]};

assign h_active = h_disp;
assign v_active = v_disp;

reg [13:0] hc;
reg [11:0] vc;

wire h_end = (hc + 14'd1 >= h_tot);
wire v_end = (vc + 12'd1 >= v_tot);

// the line that line_pre announces: the next visible line
wire [11:0] vc_next = v_end ? 12'd0 : vc + 12'd1;

always @(posedge clk_vid) begin
	line_pre    <= 0;
	frame_start <= 0;
	vbl_start   <= 0;
	if (reset) begin
		hcur <= H_RESET;
		vcur <= V_RESET;
		hc <= 0; vc <= 0;
		hs <= 0; vs <= 0; hblank <= 0; vblank <= 0; x <= 0; y <= 0;
	end
	else begin
		if (h_end) begin
			hc <= 0;
			if (v_end) begin
				vc <= 0;
				// frame boundary: take new geometry
				if (hreg_s[11:0] != 0 && hreg_s[24:19] != 0) hcur <= hreg_s;
				if (vreg_s[11:0] != 0 && vreg_s[24:19] != 0) vcur <= vreg_s;
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
		if (hc + PRE_LINE == h_tot && vc_next < v_disp) line_pre <= 1;
	end
end

endmodule
