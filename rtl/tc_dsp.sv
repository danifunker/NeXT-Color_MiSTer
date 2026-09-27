//============================================================================
//  tc_dsp -- the 68040's side of the DSP56001 host port, $02008000..$02008007
//  (Previous r1851 ioMemTabTurbo.c:130-137, mask $1E007), for the
//  NeXTstation Turbo Color.  The DSP itself runs on the MiSTer's ARM, in
//  Previous's interpreter (Main_MiSTer support/next/next_dsp.cpp and
//  support/next/dsp56k, whose dsp_core.c keeps the DSP's side: HCR, HSR,
//  HRX, HTX).  This module answers the CPU at once and trades the host
//  port's internal transfers with the ARM through a DDR3 mailbox.
//
//  "dsp_core.c:n" / "dsp.c:n" / "sysReg.c:n" = Previous r1851 src/dsp and
//  src (scratch/resources/previous-r1851-src).
//
//  Registers (byte addresses; addr2 = longword, big-endian lanes):
//    $8000 ICR  r/w  bit 0 RREQ, 1 TREQ, 3 HF0, 4 HF1, 6:5 HM (0 = interrupt
//               mode, 1/2/3 = 24/16/8-bit DMA), 7 INIT (self-clearing);
//               bit 2 reads 0 (dsp_core.c write & $FB).  INIT: with RREQ the
//               RX side is emptied, with TREQ the TX side, and the DMA byte
//               counter restarts (dsp_core.c:1179-1192).
//    $8001 CVR  r/w  bit 7 HC (host command, cleared when the DSP takes it),
//               4:0 HV; reset $12 (& $9F, dsp_core.c:1208).
//    $8002 ISR  r    bit 0 RXDF, 1 TXDE, 2 TRDY (TXDE and the DSP has read
//               every word), 3 HF2, 4 HF3 (from the DSP's HCR), 6 DMA
//               (HM != 0), 7 HREQ = (ICR & ISR) bits 1:0 (dsp_core.c:1048).
//    $8003 IVR  r/w  reset $0F.
//    $8004 TRX0 reads 0 (the unpacked DMA's pad byte), writes ignored.
//    $8005/6/7 RXH/M/L read, TXH/M/L write.  Reading RXL takes the word
//               (RXDF 0); writing TXL sends TX to the DSP (TXDE 0 until the
//               link takes it).
//  Reset values (dsp_core_reset, dsp_core.c:704-712): ICR 0, CVR $12,
//  ISR TRDY|TXDE, IVR $0F.  A DSP reset (SCR2 DSP_RESET 1 -> 0) resets the
//  host side too (DSP_Reset -> dsp_core_reset).
//
//  SCR2 (tc_scr scr2_out; sysReg.c:363-395, 405-415, 489-503):
//    bit 31 DSP_RESET: 0 -> 1 starts the DSP in mode {~bit 28, ~bit 27}
//           (DSP_Start), 1 -> 0 resets it (DSP_Reset)
//    bit 30 DSP_BLK_END: DMA block end raises the DSP's IRQB (DSP_SetIRQB)
//    bit 29 DSP_UNPKD: Turbo unpacked DMA, 4 bytes per word (dsp.c:146-148)
//    bit 23 DSP_TXD_EN: the DSP's port C bit 1 (TXD) low interrupts
//    bit  5 DSP_MEM_EN: the DSP's external memory (Turbo: DSP_EnableMemory)
//  Interrupt (scr_check_dsp_interrupt, sysReg.c:527-535): int_dsp = HREQ in
//  interrupt mode, or TXD low with DSP_TXD_EN -> status bit 14 INT_DSP_L4.
//
//  DMA (dsp.c DSP_HandleDMA:139-172): with HM != 0 and HREQ, one byte per
//  request through the PC chip's DSP channel (tc_tdma dd_*): the byte
//  counter starts at 4 - HM (24-bit: H M L; 16-bit: M L; 8-bit: L) or 4
//  when unpacked (pad, H, M, L), and each byte goes to / comes from
//  register TRXL - counter.  The direction is TREQ at the last ICR write.
//
//  The link (Main_MiSTer support/next/next_dsp.cpp has the protocol): DDR3
//  byte $30400000 (above the 2 MB of VRAM at $30000000); the FPGA word
//  (+0) {$D5F1, generation, D2H read index, H2D write index}, the ARM word
//  (+8), a 256-message ring each way (+$1000 to the ARM, +$2000 back).
//  Messages {type, epoch, data}.  To the ARM: a TX word, ICR, CVR, "RXL
//  read", DSP reset / start (mode), memory on/off, IRQB.  Back: an RX word,
//  "HRX read", HF2/HF3, "host command taken", TXD, the RESET instruction.
//  A TX word goes on the link as soon as it is written, in the order of
//  the host's accesses (an ICR / CVR written after it cannot overtake it --
//  that broke the end of a bootstrap, HF0 right after the last word);
//  TXDE counts the words the DSP has not read yet: 2, as TX + HRX.  From
//  the DSP, up to K words wait here in RX (next_dsp.cpp DSPLINK_DEPTH;
//  the real host port holds one, more buffering for the slow link).  The epoch
//  {DSP resets, TX-side INITs, RX-side INITs} drops a message that answers
//  something a reset or an INIT has since thrown away.  Until the ARM word
//  names this FPGA's generation, messages to the ARM are dropped: with no
//  DSP daemon the host port still answers, TXDE just stays 0 after K words.
//
//  Device port contract (tc_machine): stb 1-cycle, ack 1 clock later.
//============================================================================

module tc_dsp #(
	parameter CLK_HZ = 33000000,
	parameter [28:0] LINK_BASE = 29'h0608_0000     // DDR3 byte $30400000 / 8
)(
	input             clk,
	input             reset,
	// device port: $02008000 + {addr2, 2'b00}
	input             stb,
	input             we,
	input             addr2,
	input       [3:0] be,
	input      [31:0] wdata,
	output reg [31:0] rdata,
	output reg        ack,
	// SCR2 (tc_scr scr2_out)
	input      [31:0] scr2,
	// -> interrupt status bit 14 (INT_DSP_L4)
	output            int_dsp,
	// the PC chip's DSP DMA channel (tc_tdma dd_*)
	output reg        dd_req,       // level until dd_ack
	output reg        dd_we,        // 1 = a byte to memory (DSP -> host)
	output reg  [7:0] dd_wdata,
	input             dd_ack,
	input       [7:0] dd_rdata,
	input             dd_avail,     // ENABLE and Next < Limit
	input             dd_blkend,    // pulse: the channel reached Limit
	// DDR3 mailbox: one 64-bit word per request (m_req held until m_ack)
	output reg        m_req,
	output reg        m_we,
	output reg [28:0] m_addr,
	output reg [63:0] m_wdata,
	input      [63:0] m_rdata,
	input             m_ack
);

localparam integer K    = 4;                     // RX: next_dsp.cpp DSPLINK_DEPTH
localparam integer K_TX = 2;                     // TX: words the DSP has not read, as TX + HRX

// messages to the ARM (next_dsp.cpp T_*) and back (R_*)
localparam [3:0] T_TX = 4'd1, T_ICR = 4'd2, T_CVR = 4'd3, T_RXACK = 4'd4,
                 T_RESET = 4'd5, T_START = 4'd6, T_MEM = 4'd7, T_IRQB = 4'd8;
localparam [7:0] R_RX = 8'd1, R_HRXACK = 8'd2, R_FLAGS = 8'd3, R_HCACK = 8'd4,
                 R_TXD = 8'd5, R_HIRESET = 8'd6;

localparam [15:0] FPGA_MAGIC = 16'hD5F1, ARM_MAGIC = 16'hD5A1;

//----------------------------------------------------------------------------
// host side
//----------------------------------------------------------------------------

reg  [7:0] icr, cvr, ivr;
reg  [1:0] hf23;                 // ISR 4:3 = the DSP's HCR HF3/HF2
reg [23:0] tx;                   // TXH:TXM:TXL
reg        tx_full;              // TXL written, the word not yet on the link (a clock or two)
reg  [2:0] tx_out;               // words with the DSP, "HRX read" not back yet
reg [23:0] rxq [0:K-1];          // words from the DSP, oldest at rx_rd
reg  [1:0] rx_rd, rx_wr;
reg  [2:0] rx_cnt;
reg [23:0] rx_last;              // RX after the last word was taken
reg  [2:0] dma_ctr;              // DSP_HandleDMA's dma_address_counter
reg        dma_tx;               // DMA direction: TREQ at the last ICR write
reg        txd_act;              // the DSP's TXD pin is low
reg  [3:0] rgen;                 // epoch: DSP resets
reg  [1:0] itx, irx;             //        TX-side / RX-side INITs
wire [7:0] epoch = {rgen, itx, irx};

wire        rxdf     = (rx_cnt != 3'd0);
wire        txde     = !tx_full && (tx_out < K_TX[2:0]);
wire        trdy     = txde && (tx_out == 3'd0);
wire  [1:0] dma_mode = icr[6:5];
wire        hreq     = (icr[0] && rxdf) || (icr[1] && txde);
wire  [7:0] isr      = {hreq, dma_mode != 2'd0, 1'b0, hf23, trdy, txde, rxdf};
wire [23:0] rx_view  = rxdf ? rxq[rx_rd] : rx_last;

assign int_dsp = (dma_mode == 2'd0 && hreq) || (scr2[23] && txd_act);

// SCR2's DSP bits
wire       dsp_run  = scr2[31];
wire       blk_end  = scr2[30];
wire       unpacked = scr2[29];
wire [1:0] dsp_mode = {~scr2[28], ~scr2[27]};
wire       mem_en   = scr2[5];

//----------------------------------------------------------------------------
// messages to the ARM: one per clock into a 16-entry queue, in the order
// the host port produced them (a CPU access makes at most two -- ICR and
// CVR of one long write -- and the next access is clocks away)
//----------------------------------------------------------------------------

reg        p_reset, p_start, p_mem, p_icr, p_cvr, p_irqb;
reg  [1:0] p_mode;
reg        p_memv;
reg  [7:0] p_icrv, p_cvrv;
reg  [2:0] p_rxack;              // "RXL read" not yet queued

(* ramstyle = "MLAB, no_rw_check" *) reg [35:0] mq [0:15];   // {epoch, type, data[23:0]}
reg  [3:0] mq_wr, mq_rd;
reg  [4:0] mq_cnt;
wire       mq_room = (mq_cnt != 5'd16);
wire [35:0] mq_head = mq[mq_rd];

//----------------------------------------------------------------------------
// the link engine
//----------------------------------------------------------------------------

localparam [2:0] L_CTL = 3'd0, L_IDLE = 3'd1, L_SEND = 3'd2, L_ARM = 3'd3, L_ENT = 3'd4;
reg  [2:0] lst;
reg [15:0] gen = 16'd1;          // not reset: a new value after every machine reset
reg        reset_d;
reg        dsp_run_d, mem_en_d;  // SCR2 DSP_RESET / DSP_MEM_EN of the last clock
reg [15:0] h2d_wr, d2h_rd;
reg [15:0] arm_h2d_rd, arm_d2h_wr;
reg        arm_ok;               // the ARM word names this generation
reg        ctl_due;              // the FPGA word is still to be written after a reset
reg  [3:0] ent_n;                // D2H messages taken in this poll
localparam integer POLL_ACTIVE = CLK_HZ / 250000;   // 4 us while the DSP runs
localparam integer POLL_IDLE   = CLK_HZ / 1000;     // 1 ms otherwise
reg [$clog2(POLL_IDLE+1)-1:0] poll_t;
wire       poll_due = (poll_t == '0);
wire [15:0] h2d_used = h2d_wr - arm_h2d_rd;
wire        h2d_full = (h2d_used[15:8] != 8'd0);            // 256 messages unread
/* verilator lint_off UNUSEDSIGNAL */
wire [7:0]  unused_used = h2d_used[7:0];
wire [20:0] unused_scr2 = {scr2[26:24], scr2[22:6], scr2[4]} ^ {18'd0, scr2[3:1]} ^ {20'd0, scr2[0]};
/* verilator lint_on UNUSEDSIGNAL */

// one D2H message for the host side, valid for a clock
reg        d2h_v;
reg [63:0] d2h_m;
wire [7:0] d2h_type  = d2h_m[63:56];
wire [7:0] d2h_epoch = d2h_m[55:48];
wire       d2h_same_reset = (d2h_epoch[7:4] == rgen);
wire       d2h_ok_rx  = d2h_same_reset && (d2h_epoch[1:0] == irx);
wire       d2h_ok_tx  = d2h_same_reset && (d2h_epoch[3:2] == itx);
/* verilator lint_off UNUSEDSIGNAL */
wire [23:0] unused_d2h = d2h_m[47:24];
/* verilator lint_on UNUSEDSIGNAL */

//----------------------------------------------------------------------------
// the CPU access of this clock
//----------------------------------------------------------------------------

wire acc_w0   = stb && we && !addr2;
wire acc_w1   = stb && we &&  addr2;
wire icr_wr   = acc_w0 && be[3];
wire cvr_wr   = acc_w0 && be[2];
wire ivr_wr   = acc_w0 && be[0];
wire rxl_rd   = stb && !we && addr2 && be[0];
wire [7:0] icr_new = wdata[31:24] & 8'hFB;
wire [23:0] tx_new = {be[2] ? wdata[23:16] : tx[23:16],
                      be[1] ? wdata[15:8]  : tx[15:8],
                      be[0] ? wdata[7:0]   : tx[7:0]};

// DMA: the byte this request moves (DSP_HandleDMA)
wire [2:0] ctr_start = unpacked ? 3'd4 : (3'd4 - {1'b0, dma_mode});
wire [2:0] ctr_use   = ((dma_ctr == 3'd0) ? ctr_start : dma_ctr) - 3'd1;   // byte TRXL - ctr_use
reg  [2:0] dd_ctr;               // ctr_use of the byte in flight
wire       dma_go    = (dma_mode != 2'd0) && hreq && dd_avail && !dd_req;
function automatic [7:0] rx_byte;
	input [23:0] w;
	input  [2:0] c;
	begin
		case (c)
		3'd2:    rx_byte = w[23:16];   // RXH
		3'd1:    rx_byte = w[15:8];    // RXM
		3'd0:    rx_byte = w[7:0];     // RXL
		default: rx_byte = 8'h00;      // TRX0
		endcase
	end
endfunction

always_ff @(posedge clk) begin : host
	reg        push;         // a message into mq this clock
	reg  [3:0] push_t;
	reg [23:0] push_d;
	reg        pop_rx, push_rx, tx_sent, txl, init_rx, init_tx, hi_reset;
	reg [23:0] tx_w;

	ack <= stb;
	reset_d <= reset;
	if (reset && !reset_d) gen <= gen + 16'd1;

	if (reset) begin
		icr <= 8'h00; cvr <= 8'h12; ivr <= 8'h0F; hf23 <= 2'd0;
		tx <= 24'd0; tx_full <= 1'b0; tx_out <= 3'd0;
		rx_rd <= 2'd0; rx_wr <= 2'd0; rx_cnt <= 3'd0; rx_last <= 24'd0;
		dma_ctr <= 3'd0; dma_tx <= 1'b0; txd_act <= 1'b0;
		rgen <= 4'd0; itx <= 2'd0; irx <= 2'd0;
		p_reset <= 1'b0; p_start <= 1'b0; p_mem <= 1'b0; p_icr <= 1'b0;
		p_cvr <= 1'b0; p_irqb <= 1'b0; p_rxack <= 3'd0;
		p_mode <= 2'd0; p_memv <= 1'b0; p_icrv <= 8'd0; p_cvrv <= 8'd0;
		mq_wr <= 4'd0; mq_rd <= 4'd0; mq_cnt <= 5'd0;
		dd_req <= 1'b0; dd_we <= 1'b0; dd_wdata <= 8'd0; dd_ctr <= 3'd0;
		rdata <= 32'd0;
		lst <= L_IDLE; ctl_due <= 1'b1; m_req <= 1'b0; m_we <= 1'b0; m_addr <= 29'd0; m_wdata <= 64'd0;
		h2d_wr <= 16'd0; d2h_rd <= 16'd0; arm_h2d_rd <= 16'd0; arm_d2h_wr <= 16'd0;
		// ~30 us before the first access: one the mailbox port accepted
		// before this reset still completes (tc_enet_ddr)
		arm_ok <= 1'b0; ent_n <= 4'd0; poll_t <= $bits(poll_t)'(1000);
		d2h_v <= 1'b0; d2h_m <= 64'd0;
		dsp_run_d <= 1'b0; mem_en_d <= 1'b0;
	end
	else begin
		push = 1'b0; push_t = 4'd0; push_d = 24'd0;
		pop_rx = 1'b0; push_rx = 1'b0; tx_sent = 1'b0; txl = 1'b0;
		init_rx = 1'b0; init_tx = 1'b0; hi_reset = 1'b0;
		tx_w = tx;

		//------------------------------------------------------------
		// CPU reads (the value before this clock's changes)
		//------------------------------------------------------------
		if (stb) rdata <= addr2 ? {8'h00, rx_view} : {icr, cvr, isr, ivr};
		if (rxl_rd && rxdf) pop_rx = 1'b1;

		//------------------------------------------------------------
		// CPU writes (dsp_core_write_host)
		//------------------------------------------------------------
		if (icr_wr) begin
			icr <= {1'b0, icr_new[6:0]};
			if (icr_new[6:5] != 2'd0) dma_tx <= icr_new[1];
			if (icr_new[7]) begin                     // INIT
				dma_ctr <= 3'd0;
				if (icr_new[0]) init_rx = 1'b1;
				if (icr_new[1]) init_tx = 1'b1;
			end
			p_icr <= 1'b1; p_icrv <= icr_new;
		end
		if (cvr_wr) begin
			cvr <= wdata[23:16] & 8'h9F;
			p_cvr <= 1'b1; p_cvrv <= wdata[23:16] & 8'h9F;
		end
		if (ivr_wr) ivr <= wdata[7:0];
		if (acc_w1) begin
			tx_w = tx_new;
			if (be[0]) txl = 1'b1;
		end

		//------------------------------------------------------------
		// DMA bytes (DSP_HandleDMA)
		//------------------------------------------------------------
		if (dd_req && dd_ack) begin
			dd_req  <= 1'b0;
			dma_ctr <= dd_ctr;
			if (dma_tx) begin                         // memory -> TX byte
				case (dd_ctr)
				3'd2: tx_w[23:16] = dd_rdata;
				3'd1: tx_w[15:8]  = dd_rdata;
				3'd0: begin tx_w[7:0] = dd_rdata; txl = 1'b1; end
				default: ;                            // TRX0: write ignored
				endcase
			end
			else if (dd_ctr == 3'd0 && rxdf) pop_rx = 1'b1;   // RXL read
		end
		else if (dma_go && !stb) begin
			dd_req   <= 1'b1;
			dd_we    <= !dma_tx;
			dd_ctr   <= ctr_use;
			dd_wdata <= rx_byte(rx_view, ctr_use);
		end
		if (dd_blkend && blk_end) p_irqb <= 1'b1;
		tx <= tx_w;

		//------------------------------------------------------------
		// a message from the DSP (next_dsp.cpp R_*), if still current
		//------------------------------------------------------------
		if (d2h_v) begin
			case (d2h_type)
			R_RX:      if (d2h_ok_rx && rx_cnt != K[2:0]) push_rx = 1'b1;
			R_HRXACK:  if (d2h_ok_tx && tx_out != 3'd0) tx_out <= tx_out - 3'd1;
			R_FLAGS:   if (d2h_same_reset) hf23 <= d2h_m[4:3];
			R_HCACK:   if (d2h_same_reset && !cvr_wr) cvr[7] <= 1'b0;
			R_TXD:     if (d2h_same_reset) txd_act <= d2h_m[0];
			R_HIRESET: if (d2h_same_reset) hi_reset = 1'b1;
			default: ;
			endcase
		end

		//------------------------------------------------------------
		// the RX queue and TX
		//------------------------------------------------------------
		if (pop_rx) begin
			rx_last <= rxq[rx_rd];
			rx_rd   <= rx_rd + 2'd1;
			p_rxack <= p_rxack + 3'd1;
		end
		if (push_rx) begin
			rxq[rx_wr] <= d2h_m[23:0];
			rx_wr <= rx_wr + 2'd1;
		end
		rx_cnt <= rx_cnt + {2'd0, push_rx} - {2'd0, pop_rx};
		if (txl) tx_full <= 1'b1;

		//------------------------------------------------------------
		// one message into the queue: SCR2 first, then the CPU's, then
		// a TX word (TX -> HRX when the DSP has room), then IRQB
		//------------------------------------------------------------
		if (mq_room) begin
			if (p_reset) begin
				push = 1'b1; push_t = T_RESET; p_reset <= 1'b0;
			end
			else if (p_mem) begin
				push = 1'b1; push_t = T_MEM; push_d = {23'd0, p_memv}; p_mem <= 1'b0;
			end
			else if (p_start) begin
				push = 1'b1; push_t = T_START; push_d = {22'd0, p_mode}; p_start <= 1'b0;
			end
			else if (p_icr && !icr_wr) begin
				push = 1'b1; push_t = T_ICR; push_d = {16'd0, p_icrv}; p_icr <= 1'b0;
			end
			else if (p_cvr && !cvr_wr) begin
				push = 1'b1; push_t = T_CVR; push_d = {16'd0, p_cvrv}; p_cvr <= 1'b0;
			end
			else if (p_rxack != 3'd0) begin
				push = 1'b1; push_t = T_RXACK;
				p_rxack <= p_rxack + {2'd0, pop_rx} - 3'd1;
			end
			else if (tx_full && !txl && !p_icr && !icr_wr) begin
				push = 1'b1; push_t = T_TX; push_d = tx; tx_sent = 1'b1;
			end
			else if (p_irqb) begin
				push = 1'b1; push_t = T_IRQB; p_irqb <= 1'b0;
			end
		end
		if (push) begin
			mq[mq_wr] <= {epoch, push_t, push_d};
			mq_wr <= mq_wr + 4'd1;
		end
		if (tx_sent) begin
			tx_full <= 1'b0;
			tx_out  <= tx_out + 3'd1;
		end

		//------------------------------------------------------------
		// INIT (after the messages: the T_ICR carries the new epoch)
		//------------------------------------------------------------
		if (init_rx) begin
			rx_rd <= 2'd0; rx_wr <= 2'd0; rx_cnt <= 3'd0; irx <= irx + 2'd1;
		end
		if (init_tx) begin
			tx_full <= 1'b0; tx_out <= 3'd0; itx <= itx + 2'd1;
			if (dd_req) dd_req <= 1'b0;
		end

		//------------------------------------------------------------
		// the RESET instruction (dsp_cpu.c dsp_reset): ICR 0, CVR $12,
		// ISR TRDY|TXDE, IVR $0F
		//------------------------------------------------------------
		if (hi_reset) begin
			icr <= 8'h00; cvr <= 8'h12; ivr <= 8'h0F;
			tx_full <= 1'b0; dma_ctr <= 3'd0;
		end

		//------------------------------------------------------------
		// the link engine
		//------------------------------------------------------------
		d2h_v <= 1'b0;
		// the 1 ms idle period ends as soon as the DSP runs
		if (dsp_run && poll_t > POLL_ACTIVE[$bits(poll_t)-1:0])
			poll_t <= POLL_ACTIVE[$bits(poll_t)-1:0];
		else if (poll_t != '0)
			poll_t <= poll_t - 1'd1;
		case (lst)
		L_CTL: if (!m_req) begin
			// the FPGA word: magic, generation, D2H read, H2D write
			m_req   <= 1'b1; m_we <= 1'b1;
			m_addr  <= LINK_BASE;
			m_wdata <= {FPGA_MAGIC, gen, d2h_rd, h2d_wr};
		end
		else if (m_ack) begin
			m_req <= 1'b0;
			lst   <= L_IDLE;
		end

		L_IDLE: begin
			if (ctl_due) begin
				if (poll_due) begin
					ctl_due <= 1'b0;
					lst     <= L_CTL;
				end
			end
			else if (mq_cnt != 5'd0) begin
				if (!arm_ok) begin                     // no DSP daemon: drop
					mq_rd <= mq_rd + 4'd1;
				end
				else if (h2d_full) begin               // the ring is full: re-read
					lst <= L_ARM;
				end
				else begin
					m_req   <= 1'b1; m_we <= 1'b1;
					m_addr  <= LINK_BASE + 29'h200 + {21'd0, h2d_wr[7:0]};
					m_wdata <= {4'd0, mq_head[27:24], mq_head[35:28], 24'd0, mq_head[23:0]};
					lst     <= L_SEND;
				end
			end
			else if (poll_due) lst <= L_ARM;
		end

		L_SEND: if (m_ack) begin
			m_req  <= 1'b0;
			mq_rd  <= mq_rd + 4'd1;
			h2d_wr <= h2d_wr + 16'd1;
			lst    <= L_CTL;
		end

		L_ARM: if (!m_req) begin
			m_req  <= 1'b1; m_we <= 1'b0;
			m_addr <= LINK_BASE + 29'd1;
			ent_n  <= 4'd0;
		end
		else if (m_ack) begin
			m_req <= 1'b0;
			poll_t <= dsp_run ? POLL_ACTIVE[$bits(poll_t)-1:0] : POLL_IDLE[$bits(poll_t)-1:0];
			arm_ok <= (m_rdata[63:48] == ARM_MAGIC) && (m_rdata[47:32] == gen);
			arm_h2d_rd <= m_rdata[31:16];
			arm_d2h_wr <= m_rdata[15:0];
			if ((m_rdata[63:48] == ARM_MAGIC) && (m_rdata[47:32] == gen) && (m_rdata[15:0] != d2h_rd))
				lst <= L_ENT;
			else
				lst <= L_IDLE;
		end

		L_ENT: if (!m_req) begin
			m_req  <= 1'b1; m_we <= 1'b0;
			m_addr <= LINK_BASE + 29'h400 + {21'd0, d2h_rd[7:0]};
		end
		else if (m_ack) begin
			m_req  <= 1'b0;
			d2h_v  <= 1'b1;
			d2h_m  <= m_rdata;
			d2h_rd <= d2h_rd + 16'd1;
			ent_n  <= ent_n + 4'd1;
			// more waiting: take up to 16, then report the read index
			lst <= (d2h_rd + 16'd1 != arm_d2h_wr && ent_n != 4'd15) ? L_ENT : L_CTL;
		end

		default: lst <= L_CTL;
		endcase

		// the queue count: one in (push) and one out (sent or dropped) per clock
		mq_cnt <= mq_cnt + {4'd0, push}
		          - {4'd0, (lst == L_IDLE && !ctl_due && mq_cnt != 5'd0 && !arm_ok) ||
		                   (lst == L_SEND && m_ack)};

		//------------------------------------------------------------
		// SCR2: DSP reset / start and the memory enable (sysReg.c:363-383,
		// 489-496).  A DSP reset is last: it resets the host side
		// (DSP_Reset -> dsp_core_reset) and starts a new epoch.
		//------------------------------------------------------------
		dsp_run_d <= dsp_run;
		mem_en_d  <= mem_en;
		if (mem_en != mem_en_d) begin
			p_mem <= 1'b1; p_memv <= mem_en;
		end
		if (dsp_run && !dsp_run_d) begin
			p_start <= 1'b1; p_mode <= dsp_mode;
		end
		if (!dsp_run && dsp_run_d) begin
			icr <= 8'h00; cvr <= 8'h12; ivr <= 8'h0F; hf23 <= 2'd0;
			tx_full <= 1'b0; tx_out <= 3'd0;
			rx_rd <= 2'd0; rx_wr <= 2'd0; rx_cnt <= 3'd0; rx_last <= 24'd0;
			dma_ctr <= 3'd0; txd_act <= 1'b0; dd_req <= 1'b0;
			rgen <= rgen + 4'd1;
			p_reset <= 1'b1; p_start <= 1'b0;
			p_icr <= 1'b0; p_cvr <= 1'b0; p_rxack <= 3'd0; p_irqb <= 1'b0;
		end
	end
end

endmodule
