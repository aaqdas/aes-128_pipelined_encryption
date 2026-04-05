/*
Project        : AES
Standard doc.  : FIPS 197
Module name    : Top_PipelinedCipher
Description    : Implements multiple pipelined AES encryption cores
                 sharing a single key expansion unit
Author         : Amr Salah, Modified for multiple pipelines
*/

`timescale 1 ns/1 ps

module Top_PipelinedMultiCipher
#
(
    parameter DATA_W = 128,
    parameter KEY_L = 128,
    parameter NO_ROUNDS = 10,
    parameter NUM_PIPELINES = 8  // Number of parallel AES pipelines
)
(
    input clk,
    input reset,

    input  [NUM_PIPELINES-1:0] data_valid_in,
    input         cipherkey_valid_in,                  // shared key valid
    input [KEY_L-1:0] cipher_key,                      // shared cipher key
    input [NUM_PIPELINES*DATA_W-1:0] plain_text,       // plain text per pipeline

    output [NUM_PIPELINES-1:0] valid_out,              // valid out per pipeline
    output [NUM_PIPELINES*DATA_W-1:0] cipher_text      // cipher text per pipeline
);

// Shared key expansion outputs
wire [NO_ROUNDS-1:0] valid_round_key;
wire [(NO_ROUNDS*DATA_W)-1:0] W; // Round keys

// Instantiate shared KeyExpansion
KeyExpantion #(DATA_W,KEY_L,NO_ROUNDS) U_KEYEXP(clk,reset,cipherkey_valid_in,cipher_key,W,valid_round_key);


// Per-pipeline internal wiring
genvar i;
generate
    for (i = 0; i < NUM_PIPELINES; i = i + 1) begin : PIPELINES

        // Round-level wires
        wire [NO_ROUNDS-1:0] valid_round_data;
        wire [DATA_W-1:0] data_round [0:NO_ROUNDS-1];
        wire valid_sub2shift, valid_shift2key;
        wire [DATA_W-1:0] data_sub2shift, data_shift2key;
        reg  [DATA_W-1:0] data_shift2key_delayed;
        reg valid_shift2key_delayed;

        // AddRoundKey (Round 0)
        AddRoundKey #(DATA_W) U0_ARK (
            clk,
            reset,
            data_valid_in[i],
            cipherkey_valid_in,
            plain_text[(i+1)*DATA_W-1:i*DATA_W],
            cipher_key,
            valid_round_data[0],
            data_round[0]
        );

        // Main Rounds
        genvar r;
        for (r = 0; r < NO_ROUNDS-1; r = r + 1) begin : ROUNDS
            Round #(DATA_W) U_ROUND (
                clk,
                reset,
                valid_round_data[r],
                valid_round_key[r],
                data_round[r],
                W[(NO_ROUNDS-r)*DATA_W-1:(NO_ROUNDS-r-1)*DATA_W],
                valid_round_data[r+1],
                data_round[r+1]
            );
        end

        // Final Round (no MixColumns)
        SubBytes #(DATA_W) U_SUB (
            clk,
            reset,
            valid_round_data[NO_ROUNDS-1],
            data_round[NO_ROUNDS-1],
            valid_sub2shift,
            data_sub2shift
        );

        ShiftRows #(DATA_W) U_SH (
            clk,
            reset,
            valid_sub2shift,
            data_sub2shift,
            valid_shift2key,
            data_shift2key
        );

        AddRoundKey #(DATA_W) U_FINAL_ARK (
            clk,
            reset,
            valid_shift2key_delayed,
            valid_round_key[NO_ROUNDS-1],
            data_shift2key_delayed,
            W[DATA_W-1:0],
            valid_out[i],
            cipher_text[(i+1)*DATA_W-1:i*DATA_W]
        );

        // Final stage delay
        always @(posedge clk or negedge reset) begin
            if (!reset) begin
                valid_shift2key_delayed <= 1'b0;
                data_shift2key_delayed <= 'b0;
            end else begin
                if (valid_shift2key) begin
                    data_shift2key_delayed <= data_shift2key;
                end
                valid_shift2key_delayed <= valid_shift2key;
            end
        end

    end
endgenerate

endmodule
