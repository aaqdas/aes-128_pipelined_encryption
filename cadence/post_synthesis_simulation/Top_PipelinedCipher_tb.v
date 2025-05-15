/*
Project        : AES
Module         : Top_AES_PipelinedCipher testbench
*/

`timescale 1ps/1ps

module Top_PipelinedCipher_tb();

parameter DATA_W = 128;
parameter KEY_L = 128;
parameter NO_ROUNDS = 10;
parameter Clk2Q = 2;
parameter No_Patterns = 284;

reg clk;
reg reset;
reg data_valid_in;
reg cipherkey_valid_in;
reg [KEY_L-1:0] cipher_key;
reg [DATA_W-1:0] plain_text;
wire valid_out;
wire [DATA_W-1:0] cipher_text;
reg dut_error;
reg [DATA_W-1:0] data_expected;

reg [DATA_W-1:0] data_input_vectors [0:No_Patterns-1];
reg [DATA_W-1:0] cipherkey_input_vectors [0:No_Patterns-1];
reg [DATA_W-1:0] output_vectors [0:No_Patterns-1];

integer i;
integer cycle_counter;
integer input_time [0:No_Patterns-1];
integer output_time [0:No_Patterns-1];
integer latency [0:No_Patterns-1];
integer latency_sum;
integer out_index = 0;

Top_PipelinedCipher dut (
  .clk(clk),
  .reset(reset),
  .data_valid_in(data_valid_in),
  .cipherkey_valid_in(cipherkey_valid_in),
  .cipher_key(cipher_key),
  .plain_text(plain_text),
  .valid_out(valid_out),
  .cipher_text(cipher_text)
);

event terminate_sim;
event reset_enable;
event reset_done;

initial begin
  $readmemh("topcipher_data_test_inputs.txt", data_input_vectors);
  $readmemh("topcipher_key_test_inputs.txt", cipherkey_input_vectors);
  $readmemh("topcipher_test_outputs.txt", output_vectors);
end

initial begin
  $display ("###################################################");
  clk = 0;
  reset = 1;
  data_valid_in = 0;
  cipherkey_valid_in = 0;
  dut_error = 0;
end

always #469 clk = !clk;

// `ifndef GATES
// initial begin
//   $fsdbDumpfile("Top_PipelinedCipher");
//   $fsdbDumpvars(0, dut);
// end
// `endif

always @(posedge clk or negedge reset) begin
  if (!reset)
    cycle_counter <= 0;
  else
    cycle_counter <= cycle_counter + 1;
end

initial forever @ (terminate_sim) begin
  $display ("Terminating simulation");

  latency_sum = 0;
  for (i = 0; i < out_index; i = i + 1)
    latency_sum = latency_sum + latency[i];

  if (out_index > 0)
    $display ("Average Latency = %0d cycles", latency_sum / out_index);
  else
    $display ("No outputs captured, average latency unknown.");

  if (dut_error == 0)
    $display ("Simulation Result : PASSED");
  else
    $display ("Simulation Result : FAILED");

  $display ("###################################################");
  #1 $stop;
end

initial forever begin
  @(reset_enable);
  @(negedge clk)
  $display ("Applying reset");
  reset = 0;
  data_expected = 'b0;
  @(negedge clk)
  reset = 1;
  $display ("Came out of Reset");
  -> reset_done;
end

initial begin
  #10 -> reset_enable;
  @(reset_done);

  for (i = 0; i < No_Patterns; i = i + 1) begin
    @(posedge clk)
    #Clk2Q
    data_valid_in = 1;
    cipherkey_valid_in = 1;
    plain_text = data_input_vectors[i];
    cipher_key = cipherkey_input_vectors[i];
    input_time[i] = cycle_counter;
  end

  @(posedge clk)
  data_valid_in = 0;
  cipherkey_valid_in = 0;
end

initial begin
  @(reset_done);
  repeat((4 * NO_ROUNDS) + 1) @(posedge clk);
end

always @(posedge clk) begin
  if (valid_out && out_index < No_Patterns) begin
    data_expected = output_vectors[out_index];
    output_time[out_index] = cycle_counter;
    latency[out_index] = output_time[out_index] - input_time[out_index];

    $display("Pattern %0d: Latency = %0d cycles", out_index, latency[out_index]);

    if (data_expected != cipher_text) begin
      $display ("DUT ERROR AT TIME %t", $time);
      $display ("Expected Data value %h, Got Data Value %h", data_expected, cipher_text);
      dut_error = 1;
      -> terminate_sim;
    end

    out_index = out_index + 1;
    if (out_index == No_Patterns)
      -> terminate_sim;
  end
end

endmodule

