//============================================================================
//  next_sound_output -- the sound box's 44.1 kHz output stage: Previous
//  snd.c de-emphasis (snd_deemphasis_filter) and volume attenuation
//  (snd_get_volume_factor, 2 dB steps, 43 = mute), then mute.
//
//  Copied unchanged from the mono core, NeXT_MiSTer rtl/next/next_kms_snd.sv
//  (commit c5b2a71, lines 797-924), where it works on hardware.  The colour
//  core's KMS (rtl/tc_kms.sv) feeds it one {L,R} frame per sample_strobe.
//  Only the Verilator lint pragma around it is new (the -Wall unit bench).
//============================================================================

/* verilator lint_off WIDTHEXPAND */

// 44.1 kHz codec output processing. Q12 filter history preserves fractional
// feedback; Q17 coefficients follow Previous snd_deemphasis_filter. Three
// pipeline stages keep the multipliers off the FIFO-to-pin timing path.
module next_sound_output (
    input clk, reset, sample_strobe,
    input [31:0] frame,
    input mute, deemphasis,
    input [5:0] attenuation_l, attenuation_r,
    output reg signed [15:0] audio_l, audio_r
);
function automatic [16:0] gain(input [5:0] attenuation);
    begin
        case (attenuation)
            6'd0: gain = 17'd65536;
            6'd1: gain = 17'd52057;
            6'd2: gain = 17'd41350;
            6'd3: gain = 17'd32846;
            6'd4: gain = 17'd26090;
            6'd5: gain = 17'd20724;
            6'd6: gain = 17'd16462;
            6'd7: gain = 17'd13076;
            6'd8: gain = 17'd10387;
            6'd9: gain = 17'd8250;
            6'd10: gain = 17'd6554;
            6'd11: gain = 17'd5206;
            6'd12: gain = 17'd4135;
            6'd13: gain = 17'd3285;
            6'd14: gain = 17'd2609;
            6'd15: gain = 17'd2072;
            6'd16: gain = 17'd1646;
            6'd17: gain = 17'd1308;
            6'd18: gain = 17'd1039;
            6'd19: gain = 17'd825;
            6'd20: gain = 17'd655;
            6'd21: gain = 17'd521;
            6'd22: gain = 17'd414;
            6'd23: gain = 17'd328;
            6'd24: gain = 17'd261;
            6'd25: gain = 17'd207;
            6'd26: gain = 17'd165;
            6'd27: gain = 17'd131;
            6'd28: gain = 17'd104;
            6'd29: gain = 17'd83;
            6'd30: gain = 17'd66;
            6'd31: gain = 17'd52;
            6'd32: gain = 17'd41;
            6'd33: gain = 17'd33;
            6'd34: gain = 17'd26;
            6'd35: gain = 17'd21;
            6'd36: gain = 17'd16;
            6'd37: gain = 17'd13;
            6'd38: gain = 17'd10;
            6'd39: gain = 17'd8;
            6'd40: gain = 17'd7;
            6'd41: gain = 17'd5;
            6'd42: gain = 17'd4;
            default: gain = 0; // 43 and above are mute
        endcase
    end
endfunction
reg [2:0] valid;
reg use_filter, muted;
reg [16:0] gain_l, gain_r;
reg signed [27:0] input_l, input_r, previous_l, previous_r;
reg signed [27:0] history_l, history_r, filtered_l, filtered_r;
reg signed [45:0] p0_l, p1_l, p2_l, p0_r, p1_r, p2_r;
reg signed [45:0] volume_l, volume_r;
wire signed [47:0] sum_l = {{2{p0_l[45]}},p0_l} + {{2{p1_l[45]}},p1_l} + {{2{p2_l[45]}},p2_l};
wire signed [47:0] sum_r = {{2{p0_r[45]}},p0_r} + {{2{p1_r[45]}},p1_r} + {{2{p2_r[45]}},p2_r};
function automatic signed [27:0] filter_clip(input signed [47:0] sum);
    reg signed [47:0] value;
    begin
        value = sum >>> 17;
        if (value > 48'sd134217727) filter_clip = 28'sh7ffffff;
        else if (value < -48'sd134217728) filter_clip = 28'sh8000000;
        else filter_clip = value[27:0];
    end
endfunction
function automatic signed [15:0] volume_clip(input signed [45:0] product);
    reg signed [46:0] value, magnitude;
    begin
        // Q12 PCM times Q16 gain. Round symmetrically, then saturate.
        magnitude = product < 0 ? -{product[45],product} : {product[45],product};
        value = (magnitude + 47'sd134217728) >>> 28;
        if (product < 0) value = -value;
        if (value > 32767) volume_clip = 16'sh7fff;
        else if (value < -32768) volume_clip = 16'sh8000;
        else volume_clip = value[15:0];
    end
endfunction
always @(posedge clk) begin
    if (reset) begin
        valid <= 0; use_filter <= 0; muted <= 0;
        gain_l <= 0; gain_r <= 0;
        input_l <= 0; input_r <= 0; previous_l <= 0; previous_r <= 0;
        history_l <= 0; history_r <= 0; filtered_l <= 0; filtered_r <= 0;
        p0_l <= 0; p1_l <= 0; p2_l <= 0; p0_r <= 0; p1_r <= 0; p2_r <= 0;
        volume_l <= 0; volume_r <= 0; audio_l <= 0; audio_r <= 0;
    end else begin
        valid <= {valid[1:0],sample_strobe};
        if (sample_strobe) begin
            use_filter <= deemphasis; muted <= mute;
            gain_l <= gain(attenuation_l); gain_r <= gain(attenuation_r);
            input_l <= {frame[31:16],12'd0}; input_r <= {frame[15:0],12'd0};
            p0_l <= $signed({frame[31:16],12'd0}) * 18'sd60287;
            p0_r <= $signed({frame[15:0],12'd0}) * 18'sd60287;
            p1_l <= previous_l * -18'sd11511; p1_r <= previous_r * -18'sd11511;
            p2_l <= history_l * 18'sd82296; p2_r <= history_r * 18'sd82296;
            previous_l <= deemphasis ? {frame[31:16],12'd0} : 28'd0;
            previous_r <= deemphasis ? {frame[15:0],12'd0} : 28'd0;
        end
        if (valid[0]) begin
            filtered_l <= use_filter ? filter_clip(sum_l) : input_l;
            filtered_r <= use_filter ? filter_clip(sum_r) : input_r;
            history_l <= use_filter ? filter_clip(sum_l) : 28'd0;
            history_r <= use_filter ? filter_clip(sum_r) : 28'd0;
        end
        if (valid[1]) begin
            volume_l <= filtered_l * $signed({1'b0,gain_l});
            volume_r <= filtered_r * $signed({1'b0,gain_r});
        end
        if (valid[2]) begin
            audio_l <= muted ? 16'sd0 : volume_clip(volume_l);
            audio_r <= muted ? 16'sd0 : volume_clip(volume_r);
        end
    end
end
endmodule
/* verilator lint_on WIDTHEXPAND */
