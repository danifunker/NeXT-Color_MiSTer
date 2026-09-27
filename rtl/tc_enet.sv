//============================================================================
//  tc_enet -- the Turbo's AT&T 7213 Ethernet controller at $02006000 (the
//  ROM uses the $02106000 alias, HS 0.2): Previous r1851 ethernet.c's Turbo
//  model ("AT&T ethernet controller for turbo systems", ethernet.c:580-726,
//  and the register functions ethernet.c:135-292) with its internal
//  loopback, for the ROM's Ethernet POST (HS 8.5) and network-boot setup
//  (HS 8.1).  No network attachment yet: outside loopback the chip is
//  "disconnected" and a transmission ends in 16 collisions
//  (ethernet.c:711-714), which is what the ROM sees with no cable.
//
//  "HS n" = rom-dissassembly/hardware-summary.md section n; "ethernet.c:n",
//  "dma.c:n", "ioMemTabTurbo.c:n" = scratch/resources/previous-r1851-src.
//
//  Registers (byte offset, ioMemTabTurbo.c:109-124, mask $1F00F):
//    +0  TX status  r; write 1 clears (bits $BE, ethernet.c:143-145)
//    +1  TX mask    r/w, & $BE (ethernet.c:156-161)
//    +2  RX status  r; write 1 clears (bits $DF, ethernet.c:175-177)
//    +3  RX mask    r/w, & $DF (ethernet.c:188-193)
//    +4  TX mode    r/w: $80 TXMODE_ENABLE, $04 TPE, $02 LOOP (ethernet.c:581-585)
//    +5  RX mode    r/w: $80 enable, $02 own address, $01 any (ethernet.c:303-306)
//    +6  r: bit 7 = the reset bit, bit 6 BADTPE = TPE selected without a
//        twisted-pair link (EN_Control_Read, ethernet.c:589-598)
//        w: bit 7 holds the chip in reset; setting it clears TX status
//        (EN_Reset_Write / enet_reset, ethernet.c:216-220, 747-750).  The
//        ROM writes $80 and then 0 on a Turbo (enet_init $01008F06..F16;
//        only the $139 machines keep $80 until $010090DC).
//    +7  r: saved nibble & $0F (ethernet.c:600-603; tc_tdma keeps it)
//    +8..+D  node ID bytes 0..5, r/w
//    +E, +F  TX / RX sequence counters: read 0 (ethernet.c:605-613)
//  Not modelled: the RX status read bus error without TPE/LOOP and no thin
//  wire (new_enet_buserror, ethernet.c:615-626; docs/OPEN-QUESTIONS.md).
//  Interrupts: INT_EN_TX (status bit 10) = TX status & mask, INT_EN_RX
//  (bit 9) = RX status & mask (ethernet.c:102-116).
//
//  Data path (new_enet_io, ethernet.c:645-726), in hardware order:
//    TX  not in reset, TXMODE_ENABLE, the network not busy and the TX DMA
//        channel enabled: the frame is read through tc_tdma (et_*) into the
//        2 KB frame buffer until Next reaches ENADDR(Limit), then
//        dma_enet_interrupt (et_done).  LOOP: the frame is received
//        (below); otherwise TX status 16COLLS.  Then TX status READY.
//    RX  the Turbo filter (enet_packet_for_me, ethernet.c:387-402) on the
//        node ID registers: RX mode bit 7, then any ($01), or broadcast and
//        own address ($02), or broadcast only.  An accepted frame is 4 bytes
//        longer (its CRC, written as zeros here) and at least 64
//        (ethernet.c:422-425); network busy until it is stored.  With the RX
//        DMA channel enabled it is written at the channel's Next (er_*) and
//        er_eof closes it (saved limit and nibble, dma_enet_interrupt);
//        reaching Limit first chains (er_full) and continues while the
//        channel stays enabled.  A disabled channel: RX status OVERFLOW and
//        the receiver off (ethernet.c:675-682).  Stored: RX status PKT_OK
//        and, in loopback, TX status TX_RECVD (ethernet.c:689-692).
//    The frame lands at offset 0 of the buffer, as in Previous
//    (dma.c:839-843); the ROM's enet_read also copes with a deposit one
//    byte late (HS 8.1 step 5; docs/OPEN-QUESTIONS.md).
//
//  Device port (tc_machine contract): stb 1-cycle, ack one clock later;
//  addr = longword within the 16-byte window, be[3] = byte +0.
//============================================================================

module tc_enet
(
	input             clk,
	input             reset,

	// device port
	input             stb,
	input             we,
	input       [3:2] addr,
	input       [3:0] be,
	input      [31:0] wdata,
	output reg [31:0] rdata,
	output reg        ack,

	// TX DMA channel (tc_tdma et_*)
	output reg        et_req,
	input             et_ack,
	input      [31:0] et_rdata,
	input       [2:0] et_n,
	input             et_err,
	input             et_enable,
	input             et_room,
	output reg        et_done,

	// RX DMA channel (tc_tdma er_*)
	output reg        er_req,
	output reg [31:0] er_wdata,
	output reg  [2:0] er_n,
	input             er_ack,
	input             er_err,
	input             er_enable,
	input             er_room,
	output reg        er_eof,
	output reg        er_full,
	input       [3:0] er_nibble,

	output            int_en_tx,       // status bit 10
	output            int_en_rx,       // status bit 9

	// The network (rtl/next_enet_bridge.sv to Main's next_enet daemon).
	// connected = the OSD "Ethernet: Connected": a twisted-pair link, so the
	// chip is on the wire when the guest selects TPE (new_enet_state,
	// ethernet.c:628-643, bTwistedPair) and BADTPE reads clear
	// (EN_Control_Read, ethernet.c:588-597).
	input             connected,
	output reg        btx_req,         // a frame to send: the bridge reads the buffer
	output reg [10:0] btx_len,
	input      [10:0] btx_addr,
	input             btx_rd,
	output      [7:0] btx_q,
	output            btx_ack,
	input             btx_done,
	input             brx_start,       // a received frame, then brx_len bytes
	input      [10:0] brx_len,
	input             brx_valid,
	input       [7:0] brx_data,
	output            brx_ready,
	output     [47:0] guest_mac        // the node ID, for the host's MAC filter
);

localparam [7:0] TX_READY = 8'h80, TX_NET_BUSY = 8'h40, TX_RECVD = 8'h20,
                 TX_16COLLS = 8'h02;                       // ethernet.c:44-51
localparam [7:0] RX_PKT_OK = 8'h80, RX_OVERFLOW = 8'h01;   // ethernet.c:60-65

reg  [7:0] tx_status, tx_mask, rx_status, rx_mask, tx_mode, rx_mode;
reg        in_reset;                                     // +6 bit 7
reg  [7:0] mac [0:5];

wire loopback = tx_mode[1];                                // new_enet_state: LOOP first
wire badtpe   = tx_mode[2] && !connected;                  // TPE and no twisted-pair link
wire on_wire  = !loopback && tx_mode[2] && connected;      // EN_TWISTEDPAIR

assign guest_mac = {mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]};

assign int_en_tx = |(tx_status & tx_mask);
assign int_en_rx = |(rx_status & rx_mask);

//----------------------------------------------------------------------------
// frame buffer: 512 longwords, byte +0 in bits 31:24
//----------------------------------------------------------------------------
reg  [31:0] fbuf [0:511];
reg  [31:0] fq;
reg         f_we;
reg   [8:0] f_waddr, f_raddr;
reg  [31:0] f_wdata;
always @(posedge clk) begin
	if (f_we) fbuf[f_waddr] <= f_wdata;
	fq <= fbuf[f_raddr];
end

//----------------------------------------------------------------------------
// register read (sampled with stb)
//----------------------------------------------------------------------------
function automatic [7:0] reg_read;
	input [3:0] a;
	begin
		case (a)
		4'h0: reg_read = tx_status;
		4'h1: reg_read = tx_mask;
		4'h2: reg_read = rx_status;
		4'h3: reg_read = rx_mask;
		4'h4: reg_read = tx_mode;
		4'h5: reg_read = rx_mode;
		4'h6: reg_read = {in_reset, badtpe, 6'd0};
		4'h7: reg_read = {4'd0, er_nibble};
		4'h8: reg_read = mac[0];
		4'h9: reg_read = mac[1];
		4'hA: reg_read = mac[2];
		4'hB: reg_read = mac[3];
		4'hC: reg_read = mac[4];
		4'hD: reg_read = mac[5];
		default: reg_read = 8'h00;
		endcase
	end
endfunction

//----------------------------------------------------------------------------
// the data path
//----------------------------------------------------------------------------
localparam [3:0] E_IDLE = 4'd0, E_TX = 4'd1, E_SEND = 4'd2, E_RXRD = 4'd3,
                 E_RXREQ = 4'd4, E_RXCHK = 4'd5, E_RXWAIT = 4'd6,
                 E_BTX = 4'd7,    // the bridge reads the frame out of the buffer
                 E_BRX = 4'd8,    // a frame from the network streams into it
                 E_BRXEND = 4'd9;
reg   [3:0] est;
reg  [11:0] tx_len;          // bytes read (at most the buffer's 2048 are kept)
reg  [11:0] rx_len;          // bytes to store: frame + CRC, at least 64
reg  [11:0] pos;             // bytes stored so far
reg  [47:0] dst;             // destination address of the frame in the buffer

wire bcast  = (dst == 48'hFFFF_FFFF_FFFF);
wire me     = (dst == {mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]});
wire for_me = rx_mode[7] && (rx_mode[0] || bcast || (rx_mode[1] && me));

// the longword at pos: bytes at or past the frame's end read 0 (the CRC)
wire [11:0] left  = rx_len - pos;
wire  [2:0] n_now = (left >= 12'd4) ? 3'd4 : left[2:0];
wire [31:0] rx_word = {(pos + 12'd0 < tx_len) ? fq[31:24] : 8'h00,
                       (pos + 12'd1 < tx_len) ? fq[23:16] : 8'h00,
                       (pos + 12'd2 < tx_len) ? fq[15:8]  : 8'h00,
                       (pos + 12'd3 < tx_len) ? fq[7:0]   : 8'h00};
wire [11:0] tx_len4 = tx_len + 12'd4;

// The bridge's buffer reads: address on btx_rd, the byte two clocks later
// with btx_ack (f_raddr, then the registered fq).  E_BTX is the only user
// of the read port then.
reg        b_p1, b_p2;
reg  [1:0] b_lane1, b_lane2;
assign btx_ack = b_p2;
assign btx_q   = (b_lane2 == 2'd0) ? fq[31:24] : (b_lane2 == 2'd1) ? fq[23:16] :
                 (b_lane2 == 2'd2) ? fq[15:8]  : fq[7:0];

// A frame from the network is taken only while the chip is on the wire and
// idle (Previous: enet_output from RECV_STATE_WAITING in the TP state).  The
// bridge samples this once per frame; a start that finds the engine busy
// after all (a transmit began in between) drops that frame, as a busy
// receiver would.
assign brx_ready = on_wire && !in_reset && est == E_IDLE;
reg  [31:0] bw;              // the longword being assembled
reg  [10:0] brx_n;           // its length
wire [31:0] bw_next = (pos[1:0] == 2'd0) ? {brx_data, 24'd0} :
                      (pos[1:0] == 2'd1) ? {bw[31:24], brx_data, 16'd0} :
                      (pos[1:0] == 2'd2) ? {bw[31:16], brx_data, 8'd0} :
                                           {bw[31:8], brx_data};

integer i;
always @(posedge clk) begin
	ack     <= 1'b0;
	f_we    <= 1'b0;
	et_done <= 1'b0;
	er_eof  <= 1'b0;
	er_full <= 1'b0;
	if (reset) begin
		// Ethernet_Reset(hard) (ethernet.c:765-771): held in reset, TX status 0
		tx_status <= 8'd0; tx_mask <= 8'd0; rx_status <= 8'd0; rx_mask <= 8'd0;
		tx_mode <= 8'd0; rx_mode <= 8'd0; in_reset <= 1'b1;
		for (i = 0; i < 6; i = i + 1) mac[i] <= 8'd0;
		est <= E_IDLE;
		et_req <= 1'b0; er_req <= 1'b0; er_wdata <= 32'd0; er_n <= 3'd0;
		tx_len <= 12'd0; rx_len <= 12'd0; pos <= 12'd0; dst <= 48'd0;
		f_waddr <= 9'd0; f_raddr <= 9'd0; f_wdata <= 32'd0;
		rdata <= 32'd0;
		btx_req <= 1'b0; btx_len <= 11'd0;
		b_p1 <= 1'b0; b_p2 <= 1'b0; b_lane1 <= 2'd0; b_lane2 <= 2'd0;
		bw <= 32'd0; brx_n <= 11'd0;
	end
	else begin
		b_p1    <= 1'b0;
		b_p2    <= b_p1;
		b_lane2 <= b_lane1;
		//------------------------------------------------------------
		// data path
		//------------------------------------------------------------
		case (est)
		E_IDLE: begin
			if (brx_start && brx_ready) begin
				// a frame from the network (enet_output -> enet_receive)
				brx_n <= brx_len;
				pos   <= 12'd0;
				dst   <= 48'd0;
				est   <= E_BRX;
			end
			else if (!in_reset && tx_mode[7] && !tx_status[6] && et_enable) begin
				tx_len  <= 12'd0;
				f_waddr <= 9'd0;
				et_req  <= et_room;
				est     <= E_TX;
			end
		end
		E_TX: begin
			if (et_ack) begin
				et_req <= 1'b0;
				if (tx_len < 12'd2048) begin
					f_we    <= 1'b1;
					f_wdata <= et_rdata;
					f_waddr <= tx_len[10:2];
					tx_len  <= tx_len + {9'd0, et_n};
				end
				if (tx_len == 12'd0) dst[47:16] <= et_rdata;
				if (tx_len == 12'd4) dst[15:0]  <= et_rdata[31:16];
				if (et_room && et_enable) et_req <= 1'b1;   // Next already advanced
				else begin
					et_done <= 1'b1;                        // dma_enet_interrupt(TX)
					est     <= E_SEND;
				end
			end
			else if (et_err) begin
				et_req <= 1'b0;
				est    <= E_SEND;
			end
			else if (!et_req) begin
				// the frame is empty (Next already at the end)
				et_done <= 1'b1;
				est     <= E_SEND;
			end
		end
		E_SEND: begin
			// ethernet.c:709-723: nothing read -> nothing sent; disconnected ->
			// 16 collisions; loopback -> enet_receive (ethernet.c:418-431);
			// then TXSTAT_READY
			est <= E_IDLE;
			if (tx_len != 12'd0) begin
				if (on_wire) begin
					// enet_send: the bridge copies the frame to Main's TX ring
					// (at most 1600 bytes, the daemon's MAX_FRAME)
					btx_req <= 1'b1;
					btx_len <= (tx_len > 12'd1600) ? 11'd1600 : tx_len[10:0];
					est     <= E_BTX;
				end
				else if (!loopback)
					tx_status <= tx_status | TX_16COLLS | TX_READY;
				else if (for_me) begin
					tx_status <= tx_status | TX_NET_BUSY | TX_READY;
					rx_len    <= (tx_len4 < 12'd64) ? 12'd64 : tx_len4;
					pos       <= 12'd0;
					est       <= E_RXCHK;
				end
				else tx_status <= tx_status | TX_READY;
			end
		end
		E_BTX: begin
			if (btx_rd) begin
				f_raddr <= btx_addr[10:2];
				b_lane1 <= btx_addr[1:0];
				b_p1    <= 1'b1;
			end
			if (btx_done) begin
				btx_req   <= 1'b0;
				tx_status <= tx_status | TX_READY;
				est       <= E_IDLE;
			end
		end
		E_BRX: begin
			// store the frame at offset 0 of the buffer, as a loopback one
			if (brx_valid) begin
				bw <= bw_next;
				if (pos[1:0] == 2'd3 || pos + 12'd1 == {1'b0, brx_n}) begin
					f_we    <= 1'b1;
					f_waddr <= pos[10:2];
					f_wdata <= bw_next;
				end
				if (pos < 12'd6) dst[47 - 8 * pos[2:0] -: 8] <= brx_data;
				pos <= pos + 12'd1;
				if (pos + 12'd1 == {1'b0, brx_n}) est <= E_BRXEND;
			end
		end
		E_BRXEND: begin
			// enet_receive (ethernet.c:418-431): the filter, then the frame
			// + CRC, at least 64 bytes, through the receive path below.
			// tx_len is the stored length there (bytes past it read 0).
			tx_len <= {1'b0, brx_n};
			pos    <= 12'd0;
			if (for_me) begin
				tx_status <= tx_status | TX_NET_BUSY;
				rx_len    <= ({1'b0, brx_n} + 12'd4 < 12'd64) ? 12'd64 : {1'b0, brx_n} + 12'd4;
				est       <= E_RXCHK;
			end
			else est <= E_IDLE;
		end
		E_RXWAIT: begin
			// tc_tdma chains on the clock that sees er_full
			est <= E_RXCHK;
		end
		E_RXCHK: begin
			// receiving: the channel must be enabled and have room
			if (er_enable && er_room) begin
				f_raddr <= pos[10:2];
				est     <= E_RXRD;
			end
			else begin
				// ethernet.c:675-682: receiver overflow, the receiver goes off
				rx_status <= rx_status | RX_OVERFLOW;
				rx_mode   <= rx_mode & 8'h7F;
				tx_status <= tx_status & ~TX_NET_BUSY;
				est       <= E_IDLE;
			end
		end
		E_RXRD: begin
			// fq holds the longword at pos from here on
			est <= E_RXREQ;
		end
		E_RXREQ: begin
			if (!er_req && !er_ack) begin
				er_req   <= 1'b1;
				er_wdata <= rx_word;
				er_n     <= n_now;
			end
			if (er_ack) begin
				er_req <= 1'b0;
				pos    <= pos + {9'd0, er_n};
				if (pos + {9'd0, er_n} >= rx_len) begin
					// ethernet.c:687-695 with dma.c:850-868
					// TX_RECVD only in loopback (new_enet_io, ethernet.c:687-693)
					er_eof    <= 1'b1;
					rx_status <= rx_status | RX_PKT_OK;
					tx_status <= (tx_status & ~TX_NET_BUSY) | (loopback ? TX_RECVD : 8'h00);
					est       <= E_IDLE;
				end
				else if (!er_room) begin
					er_full <= 1'b1;                        // Limit reached: chain
					est     <= E_RXWAIT;
				end
				else begin
					f_raddr <= (pos[10:2] + 9'd1);
					est     <= E_RXRD;
				end
			end
			else if (er_err) begin
				er_req    <= 1'b0;
				tx_status <= tx_status & ~TX_NET_BUSY;
				est       <= E_IDLE;
			end
		end
		default: est <= E_IDLE;
		endcase

		//------------------------------------------------------------
		// register access (after the data path: a CPU write wins)
		//------------------------------------------------------------
		if (stb) begin
			ack   <= 1'b1;
			rdata <= {reg_read({addr, 2'd0}), reg_read({addr, 2'd1}),
			          reg_read({addr, 2'd2}), reg_read({addr, 2'd3})};
			if (we) begin : wr
				integer l;
				reg [3:0] a;
				reg [7:0] v;
				for (l = 0; l < 4; l = l + 1) if (be[3 - l]) begin
					a = {addr, l[1:0]};
					v = wdata[31 - 8 * l -: 8];
					case (a)
					4'h0: tx_status <= tx_status & ~(v & 8'hBE);
					4'h1: tx_mask   <= v & 8'hBE;
					4'h2: rx_status <= rx_status & ~(v & 8'hDF);
					4'h3: rx_mask   <= v & 8'hDF;
					4'h4: tx_mode   <= v;
					4'h5: rx_mode   <= v;
					4'h6: begin
						in_reset <= v[7];
						if (v[7]) tx_status <= 8'd0;
					end
					4'h8: mac[0] <= v;
					4'h9: mac[1] <= v;
					4'hA: mac[2] <= v;
					4'hB: mac[3] <= v;
					4'hC: mac[4] <= v;
					4'hD: mac[5] <= v;
					default: ;
					endcase
				end
			end
		end
	end
end

endmodule
