//============================================================================
//  tc_tmc -- Turbo Memory Controller registers at $02200000 (64 KB window),
//  with the ADB interface at $02208000.
//
//  Sources: Previous r1851 tmc.c (register file, reset values) and adb.c
//  (ADB register semantics); rom-dissassembly/hardware-summary.md sections
//  1.1, 2 and 5 ("HS" below).  All ROM accesses are 32-bit longs.
//
//  $0000 SCR1 copy (read only)  HS 1.1; tmc.c tmc_scr1_reset():
//        $FFFF5FDF = slot $F | type 5 (Turbo Color) | cpu 7 (33 MHz) |
//        mem field 1 (70 ns) | TURBOSCR_FMASK $0FFF0F08.  The ROM reads
//        $0200C000 first (type 4) and then this copy.
//  $0004 parity data     write: clears the latch; read 0 (HS 2.2; Previous
//  $0008 parity address  leaves all three unimplemented; this core has no
//  $000C parity status   parity, so nothing ever latches)
//  $0010 control         r/w long, reset $0D17038F (tmc.c TMC_Reset).
//        Bit 10 (parity check enable) is forced to 0 on write, as Previous
//        tmc_ctrl_write2 does ("no parity memory"): the ROM's parity probe
//        (HS 3.3) then sees the bit drop and decides the SIMMs have no
//        parity without an NMI ever being raised.
//  $0020 NMI             byte 3 bit 0 r/w; 1 asserts INT_NMI (status bit 31)
//        (tmc.c tmc_nmi_write3; HS 2.3)
//  $0080 video interrupt byte 0: bit 24 INTERRUPT (pending; write 1 clears),
//        bit 25 INT_MASK (frame interrupt -> status bit 13), bit 26 ENABLE
//        (video on).  tmc.c tmc_vir_write0 / tmc_video_interrupt; HS 2.4.
//  $0088 horizontal / $008C vertical timing, r/w, reset $31048118 /
//        $10430340 (tmc.c tmc_video_reg_reset; HS 2.5; tc_vtiming.sv).
//  other offsets below $8000 read 0, writes ignored (tmc.c unimpl).
//
//  ADB ($8000 + ...), adb.c registers, low byte only (HS 5):
//   +00 INTSTATUS (r, write-1-to-clear) +08 INTMASK (rw) +10 SETINT (w)
//   +18 CONFIG (rw) +20 CTRL (w) +28 STATUS (r) +30 CMD (rw) +38 COUNT (rw)
//   +80 DATA0 +88 DATA1 (rw).  Other offsets bus-error (adb.c
//   adb_read_register default).
//   No ADB device is attached (docs/DECISIONS.md: KMS first).  That is the
//   ROM's no-device path (HS 5, "minimum behaviour"): CTRL RESET_ADB raises
//   INT RESET; CTRL XMIT_CMD runs the command, and every command times out
//   (STATUS TIMEOUT, INT ACCESS, DATAPEND clear), exactly as adb.c's
//   adb_command() answers an unknown address.  The ADB interrupt
//   (intstatus & intmask) shares status bit 13 with the frame interrupt
//   (adb.c adb_check_interrupt; the ROM keeps INTMASK at 0).
//
//  Device port contract (tc_machine): stb is a 1-cycle strobe, ack a 1-cycle
//  pulse one clock later with rdata; be[3] = byte at longword+0.
//============================================================================

module tc_tmc
(
	input             clk,
	input             reset,

	input             stb,
	input             we,
	input      [15:2] addr,
	input       [3:0] be,
	input      [31:0] wdata,
	output reg [31:0] rdata,
	output reg        ack,
	output reg        berr,          // with ack: this access takes a bus error

	input             vbl_pulse,     // one clk pulse per frame (start of vertical blank)

	output     [31:0] hreg,
	output     [31:0] vreg,
	output            video_enable,
	output            int_video,     // -> interrupt status bit 13 (INT_DISK / C16VIDEO)
	output            int_nmi,       // -> interrupt status bit 31
	output     [31:0] control
);

localparam [31:0] SCR1_TC   = 32'hFFFF5FDF;
localparam [31:0] CTRL_RST  = 32'h0D17038F;
localparam [31:0] H_RESET   = 32'h31048118;
localparam [31:0] V_RESET   = 32'h10430340;

reg [31:0] ctrl;
reg        nmi;
reg  [2:0] vir;          // {ENABLE, INT_MASK, INTERRUPT}
reg [31:0] hcfg, vcfg;

// ADB
reg  [7:0] adb_intstatus, adb_intmask, adb_config, adb_status, adb_cmd;
reg  [6:0] adb_count;
reg [31:0] adb_data0, adb_data1;

assign hreg         = hcfg;
assign vreg         = vcfg;
assign video_enable = vir[2];
assign int_video    = vir[0] | |(adb_intstatus & adb_intmask);
assign int_nmi      = nmi;
assign control      = ctrl;

// byte-lane merge of a register write
function [31:0] merge;
	input [31:0] old, d;
	input  [3:0] b;
	begin
		merge = {b[3] ? d[31:24] : old[31:24], b[2] ? d[23:16] : old[23:16],
		         b[1] ? d[15:8]  : old[15:8],  b[0] ? d[7:0]   : old[7:0]};
	end
endfunction

wire        is_adb = addr[15];
wire  [7:0] adb_off = {addr[7:2], 2'b00};
wire [31:0] ctrl_w  = merge(ctrl, wdata, be);

always @(posedge clk) begin
	ack  <= 0;
	berr <= 0;
	if (reset) begin
		ctrl <= CTRL_RST;
		nmi  <= 0;
		vir  <= 0;
		hcfg <= H_RESET;
		vcfg <= V_RESET;
		adb_intstatus <= 0; adb_intmask <= 0; adb_config <= 0; adb_status <= 0;
		adb_cmd <= 0; adb_count <= 0; adb_data0 <= 0; adb_data1 <= 0;
		rdata <= 0;
	end
	else begin
		if (stb) begin
			ack   <= 1;
			rdata <= 0;
			if (!is_adb) begin
				case ({addr[15:2], 2'b00})
				16'h0000: rdata <= SCR1_TC;
				16'h0010: begin
					rdata <= ctrl;
					if (we) ctrl <= {ctrl_w[31:11], 1'b0, ctrl_w[9:0]};
				end
				16'h0020: begin
					rdata <= {31'd0, nmi};
					if (we && be[0]) nmi <= wdata[0];
				end
				16'h0080: begin
					rdata <= {5'd0, vir, 24'd0};
					if (we && be[3]) begin
						// tmc_vir_write0: store ENABLE/INT_MASK; a written INTERRUPT
						// bit clears the pending frame interrupt (INT_DISK)
						vir[2:1] <= wdata[26:25];
						if (wdata[24]) vir[0] <= 1'b0;
					end
				end
				16'h0088: begin
					rdata <= hcfg;
					if (we) hcfg <= merge(hcfg, wdata, be);
				end
				16'h008C: begin
					rdata <= vcfg;
					if (we) vcfg <= merge(vcfg, wdata, be);
				end
				default: ;       // $0004..$000C parity, others: read 0, write ignored
				endcase
			end
			else begin
				case (adb_off)
				8'h00: begin
					rdata <= {24'd0, adb_intstatus};
					if (we && be[0]) adb_intstatus <= adb_intstatus & ~wdata[7:0];
				end
				8'h08: begin
					rdata <= {24'd0, adb_intmask};
					if (we && be[0]) adb_intmask <= wdata[7:0];
				end
				8'h10: if (we && be[0]) adb_intstatus <= adb_intstatus | wdata[7:0];
				8'h18: begin
					rdata <= {24'd0, adb_config};
					if (we && be[0]) adb_config <= wdata[7:0];
				end
				8'h20: if (we && be[0]) begin
					// adb_control_write
					if (wdata[3]) begin                          // RESET_ADB
						adb_status    <= adb_status & ~8'h40;       // ~POLL_EN
						adb_intstatus <= adb_intstatus | 8'h08;     // INT RESET
					end
					if (wdata[2]) begin                          // XMIT_CMD
						if (|(adb_status & 8'h70))                   // RESET|POLL_EN|ACCESS
							adb_intstatus <= adb_intstatus | 8'h01; // INT REJECT
						else begin
							// no device at any address: every command times out
							adb_status    <= (adb_status & ~8'h0E) | 8'h04;
							adb_intstatus <= adb_intstatus | 8'h04 | (wdata[3] ? 8'h08 : 8'h00);
						end
					end
					if (wdata[1]) adb_status <= adb_status & ~8'h40;  // DIS_POLL
				end
				8'h28: rdata <= {24'd0, adb_status};
				8'h30: begin
					rdata <= {24'd0, adb_cmd};
					if (we && be[0]) adb_cmd <= wdata[7:0];
				end
				8'h38: begin
					rdata <= {25'd0, adb_count};
					if (we && be[0]) adb_count <= wdata[6:0];
				end
				8'h80: begin
					rdata <= adb_data0;
					if (we) adb_data0 <= merge(adb_data0, wdata, be);
				end
				8'h88: begin
					rdata <= adb_data1;
					if (we) adb_data1 <= merge(adb_data1, wdata, be);
				end
				default: berr <= 1;
				endcase
			end
		end

		// frame interrupt: raised once per frame while INT_MASK is set
		// (tmc_video_interrupt); a set in the clock of an ack wins
		if (vbl_pulse && vir[1]) vir[0] <= 1'b1;
	end
end

endmodule
