//============================================================================
//  tc_esp_mini -- NCR 53C90 ("ESP") register stand-in at $02014000
//  ($02114000 alias), until the full SCSI model (NeXT_MiSTer next_scsi.sv +
//  the TDMA channel) is ported for SCSI boot (milestone M4).
//
//  Enough for the paths that reach the prompt (hardware-summary 9, "HS"):
//  * the $704 device-init writes: DMA control $02114020 = $02 (reset),
//    command $03 (SCSI bus reset) -- HS 0.3 step 14;
//  * the POST SCSI test (HS 9.5, post_scsi_test $01004a2a): DMA control
//    reset, commands $02 (chip reset) and $00 (NOP), five bytes into the FIFO,
//    FIFO flags (+7 bits 4:0) = 5, two bytes back out in order, flags = 3;
//  * the extended POST's register checks: $01 flush -> flags 0; transfer
//    count +0/+1 loaded by command $80 (DMA NOP) and read back; config +8
//    read/write; an illegal command sets interrupt status bit 6.
//  No SCSI bus, no targets, no DMA and no interrupt line (int_scsi stays 0):
//  a bus reset is accepted silently.
//
//  Registers (Previous esp.c / ioMemTabTurbo.c): +0 count low, +1 count high,
//  +2 FIFO, +3 command, +4 status (r) / bus ID (w), +5 interrupt status (r,
//  clears) / select timeout (w), +6 sequence step (r) / sync period (w),
//  +7 FIFO flags (r) / sync offset (w), +8 config 1, +9 clock factor (w),
//  +A test (w), +B config 2; +$20 SCSI DMA control (bit 1 = ESP reset),
//  +$21 DMA FIFO status.  Byte registers: +n is lane 3 - (n & 3).
//
//  Device port contract (tc_machine): stb 1-cycle, ack 1-cycle later.
//============================================================================

module tc_esp_mini
(
	input             clk,
	input             reset,

	input             stb,
	input             we,
	input       [5:2] addr,          // longword within $02014000..$0201403F
	input       [3:0] be,
	input      [31:0] wdata,
	output reg [31:0] rdata,
	output reg        ack
);

reg  [7:0] fifo [0:15];
reg  [3:0] rd_p, wr_p;
reg  [4:0] cnt;
reg  [7:0] tc_lo, tc_hi, tc_lo_cur, tc_hi_cur;
reg  [7:0] config1, config2, dma_ctrl, intstat;

wire [1:0] lane = be[3] ? 2'd0 : be[2] ? 2'd1 : be[1] ? 2'd2 : 2'd3;
wire [5:0] reg_a = {addr, lane};                 // byte offset of the register
wire [7:0] wb    = (lane == 2'd0) ? wdata[31:24] : (lane == 2'd1) ? wdata[23:16] :
                   (lane == 2'd2) ? wdata[15:8]  : wdata[7:0];

task chip_reset;
	begin
		rd_p <= 0; wr_p <= 0; cnt <= 0;
		config1 <= 0; config2 <= 0; intstat <= 0;
		tc_lo_cur <= 0; tc_hi_cur <= 0;
	end
endtask

reg [7:0] rb;
always @(posedge clk) begin
	ack <= 0;
	if (reset) begin
		chip_reset;
		tc_lo <= 0; tc_hi <= 0;
		dma_ctrl <= 0;
		rdata <= 0;
	end
	else if (stb) begin
		ack <= 1;
		rb = 8'd0;
		case (reg_a)
		6'h00: begin rb = tc_lo_cur; if (we) tc_lo <= wb; end
		6'h01: begin rb = tc_hi_cur; if (we) tc_hi <= wb; end
		6'h02: begin
			if (we) begin
				if (cnt != 5'd16) begin
					fifo[wr_p] <= wb;
					wr_p <= wr_p + 4'd1;
					cnt  <= cnt + 5'd1;
				end
			end
			else begin
				rb = fifo[rd_p];
				if (cnt != 0) begin
					rd_p <= rd_p + 4'd1;
					cnt  <= cnt - 5'd1;
				end
			end
		end
		6'h03: if (we) begin
			case (wb & 8'h7F)
			8'h00: ;                                         // NOP
			8'h01: begin rd_p <= 0; wr_p <= 0; cnt <= 0; end // flush FIFO
			8'h02: chip_reset;                               // reset chip
			8'h03: ;                                         // reset SCSI bus: no bus
			default: if (!(wb[7] && (wb & 8'h7F) == 8'h00))
				intstat <= intstat | 8'h40;                  // illegal command
			endcase
			if (wb[7]) begin                                 // DMA commands load the counter
				tc_lo_cur <= tc_lo;
				tc_hi_cur <= tc_hi;
			end
		end
		6'h04: rb = 8'h00;                                   // status
		6'h05: if (!we) begin rb = intstat; intstat <= 0; end
		6'h06: rb = 8'h00;                                   // sequence step
		6'h07: rb = {3'd0, cnt};                             // FIFO flags
		6'h08: begin rb = config1; if (we) config1 <= wb; end
		6'h0B: begin rb = config2; if (we) config2 <= wb; end
		6'h20: begin
			rb = dma_ctrl;
			if (we) begin
				dma_ctrl <= wb;
				if (wb[1]) chip_reset;                       // ESPCTRL_RESET
			end
		end
		6'h21: rb = 8'h00;
		default: ;
		endcase
		rdata <= {rb, rb, rb, rb};
	end
end

endmodule
