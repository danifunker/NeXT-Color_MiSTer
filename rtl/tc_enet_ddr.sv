//============================================================================
//  tc_enet_ddr -- the Ethernet bridge's mailbox port onto the DDRAM port
//  that tc_vram (via tc_memsys) otherwise owns alone.
//
//  The bridge (rtl/next_enet_bridge.sv, NeXT_MiSTer's) runs on clk_sys next
//  to tc_enet and makes one 64-bit mailbox access at a time (m_req level,
//  held with its address/data until m_ack).  The DDRAM port runs on clk_ram,
//  exactly 3x clk_sys from the same PLL and phase aligned (rtl/pll), so the
//  request and its completion cross as toggles on plain timed multi-rate
//  paths, as tc_vram's CPU beats do (no synchronisers).  The address, data
//  and read word are held stable across the crossing by the handshake.
//
//  NeXT_MiSTer's next_ddram_arb (rtl/next_ddram_arb.sv) serialises the two:
//  port A = tc_vram's DDRAM traffic, passed through and always first; the
//  bridge (port B) gets a single-beat slot only when port A has nothing
//  requested or in flight.  The bridge's traffic is a few words per frame
//  plus one pointer read every 200 us, against the scan-out's line bursts.
//
//  The toggles are never reset: a machine reset in the middle of an access
//  lets it finish on the clk_ram side, and the (reset) bridge ignores the
//  late acknowledge.
//============================================================================

module tc_enet_ddr
(
	input             clk_sys,
	input             clk_ram,
	input             reset_ram,      // arbiter reset (clk_ram)

	// the bridge's mailbox port (clk_sys)
	input             s_req,
	input             s_we,
	input      [28:0] s_addr,
	input      [63:0] s_wdata,
	output     [63:0] s_rdata,
	output reg        s_ack = 1'b0,

	// port A: tc_memsys's DDRAM master (clk_ram)
	output            a_busy,
	input       [7:0] a_burstcnt,
	input      [28:0] a_addr,
	output     [63:0] a_dout,
	output            a_dout_ready,
	input             a_rd,
	input      [63:0] a_din,
	input       [7:0] a_be,
	input             a_we,

	// the DDRAM port (clk_ram)
	input             DDRAM_BUSY,
	output      [7:0] DDRAM_BURSTCNT,
	output     [28:0] DDRAM_ADDR,
	input      [63:0] DDRAM_DOUT,
	input             DDRAM_DOUT_READY,
	output            DDRAM_RD,
	output     [63:0] DDRAM_DIN,
	output      [7:0] DDRAM_BE,
	output            DDRAM_WE
);

// clk_sys side: one request toggle per access, completion seen as a toggle
reg rq_t = 1'b0, dn_seen = 1'b0, busy_s = 1'b0;
reg dn_t = 1'b0;                  // clk_ram
always @(posedge clk_sys) begin
	s_ack <= 1'b0;
	// !s_ack: the bridge drops m_req on the clock it sees the ack
	if (s_req && !busy_s && !s_ack) begin
		rq_t   <= ~rq_t;
		busy_s <= 1'b1;
	end
	if (busy_s && dn_t != dn_seen) begin
		dn_seen <= dn_t;
		busy_s  <= 1'b0;
		s_ack   <= 1'b1;
	end
end

// clk_ram side: a new toggle raises the arbiter's port B request
reg        rq_seen = 1'b0, b_req = 1'b0;
wire       b_ack;
always @(posedge clk_ram) begin
	if (!b_req && rq_t != rq_seen) b_req <= 1'b1;
	if (b_req && b_ack) begin
		b_req   <= 1'b0;
		rq_seen <= rq_t;
		dn_t    <= ~dn_t;
	end
end

next_ddram_arb arb (
	.clk(clk_ram), .reset(reset_ram),
	.a_rd(a_rd), .a_we(a_we), .a_addr(a_addr), .a_din(a_din), .a_be(a_be),
	.a_burst(a_burstcnt), .a_busy(a_busy), .a_dout(a_dout), .a_dout_ready(a_dout_ready),
	.b_req(b_req), .b_we(s_we), .b_addr(s_addr), .b_wdata(s_wdata),
	.b_rdata(s_rdata), .b_ack(b_ack),
	.DDRAM_BUSY(DDRAM_BUSY), .DDRAM_BURSTCNT(DDRAM_BURSTCNT), .DDRAM_ADDR(DDRAM_ADDR),
	.DDRAM_DOUT(DDRAM_DOUT), .DDRAM_DOUT_READY(DDRAM_DOUT_READY), .DDRAM_RD(DDRAM_RD),
	.DDRAM_DIN(DDRAM_DIN), .DDRAM_BE(DDRAM_BE), .DDRAM_WE(DDRAM_WE)
);

endmodule
