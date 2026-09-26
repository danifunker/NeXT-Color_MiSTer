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
//  Other channels (sound out/in, printer, DSP, Ethernet TX/RX): register
//  model only.  Their CSR status bits are flip-flops (same command
//  semantics); their Next/Limit/Start/Stop and the plain registers live in
//  one 32-word RAM (no reset: block RAM / MLAB).  HOOK: to give a channel
//  an engine, move its four pointers out of that RAM into flip-flops like
//  the SCSI set below, add a client port like sc_* and arbitrate the
//  memory master between the clients (the machine sees one master).  Their
//  COMPLETE bits already drive the interrupt outputs.
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

// Ethernet RX saved limit (dma.c:1180): written by the RX engine in
// Previous (ethernet.c); no engine yet.  HOOK.
wire [31:0] en_rx_saved_limit = 32'd0;

assign sc_enable   = c_en[C_SCSI];
assign sc_dev2m    = c_dir[C_SCSI];
assign sc_room     = s_next < s_limit;
assign sc_at_limit = s_next == s_limit;

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
wire       ram_hit = ((is_ptr || is_init) && ch != C_SCSI) || is_plain;
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
		         (is_ptr  && ch == C_SCSI) ? s_ptr_q :
		         (is_init && ch == C_SCSI) ? s_next : 32'd0;
	end
	if (p_stb) rdata <= p_ram ? ram_q : p_ff;
end

//----------------------------------------------------------------------------
// SCSI channel engine and register writes
//----------------------------------------------------------------------------
reg eval_pend;      // an eval arrived while a word was in flight
reg orphan;         // the client dropped its request before the word finished

always @(posedge clk) begin : engine
	reg ev;         // a completion or fault on this clock (CLRCOMPLETE loses)
	ev = 1'b0;
	sc_ack <= 1'b0;
	sc_err <= 1'b0;
	if (reset) begin
		// DMA_Reset (dma.c:1226): every CSR cleared
		c_en <= 8'd0; c_sup <= 8'd0; c_cmp <= 8'd0; c_bex <= 8'd0; c_dir <= 8'd0;
		s_next <= 32'd0; s_limit <= 32'd0; s_start <= 32'd0; s_stop <= 32'd0;
		m_req <= 1'b0; m_we <= 1'b0; m_addr <= 30'd0; m_be <= 4'h0; m_wdata <= 32'd0;
		sc_rdata <= 32'd0;
		eval_pend <= 1'b0;
		orphan <= 1'b0;
	end
	else begin
		//------------------------------------------------------------
		// one longword at Next for the client
		//------------------------------------------------------------
		if (m_req) begin
			if (!sc_req) orphan <= 1'b1;
			if (m_err) begin
				// dma.c:445-449: the channel stops, COMPLETE|BUSEXC
				m_req <= 1'b0;
				orphan <= 1'b0;
				sc_err <= sc_req && !orphan;
				c_en[C_SCSI]  <= 1'b0;
				c_cmp[C_SCSI] <= 1'b1;
				c_bex[C_SCSI] <= 1'b1;
				ev = 1'b1;
			end
			else if (m_ack) begin
				m_req <= 1'b0;
				orphan <= 1'b0;
				sc_ack <= sc_req && !orphan;
				sc_rdata <= m_rdata;
				// a malformed limit must not carry Next past it (next_scsi)
				s_next <= (s_next + 32'd4 > s_limit) ? s_limit : s_next + 32'd4;
			end
		end
		else if (sc_req && !sc_ack && !sc_err) begin
			m_req   <= 1'b1;
			m_we    <= sc_we;
			m_addr  <= s_next[31:2];
			m_be    <= 4'hF;
			m_wdata <= sc_wdata;
		end

		//------------------------------------------------------------
		// dma_interrupt() (dma.c:361-381).  Its callers return early on a
		// disabled channel (dma.c:391, 455, 501), hence the ENABLE test.
		//------------------------------------------------------------
		if ((sc_eval || eval_pend) && m_req)
			eval_pend <= 1'b1;
		else if (sc_eval || eval_pend) begin
			eval_pend <= 1'b0;
			if (c_en[C_SCSI] && s_next >= s_limit) begin
				ev = 1'b1;
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
		// register writes (after the engine: RESET wins over a completion)
		//------------------------------------------------------------
		if (stb && we) begin
			if (is_csr) begin
				// TDMA_CSR_Write (dma.c:1120-1178)
				c_dir[ch] <= wcmd[2];
				if (wcmd[4]) begin                      // RESET
					c_en[ch]  <= 1'b0;
					c_sup[ch] <= 1'b0;
					c_cmp[ch] <= 1'b0;
				end
				if (wcmd[1]) c_sup[ch] <= 1'b1;         // SETSUPDATE
				if (wcmd[0]) begin                      // SETENABLE
					if (ch == C_SCSI && (s_next[1:0] != 2'd0 || s_limit[3:0] != 4'd0)) begin
						c_en[C_SCSI]  <= 1'b0;
						c_cmp[C_SCSI] <= 1'b1;
						c_bex[C_SCSI] <= 1'b1;
						ev = 1'b1;
					end
					else c_en[ch] <= 1'b1;
				end
				// CLRCOMPLETE, conditional (see the header)
				if (wcmd[3] && (c_en[ch] || wcmd[0]) && !(ch == C_SCSI && ev))
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
			if (is_init && ch == C_SCSI) s_next <= init_val;
		end
	end
end

endmodule
