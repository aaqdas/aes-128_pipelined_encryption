module SBox_SRAM (
    input clk,
    input reset,
    input valid_in,
    input [7:0] addr_in,
    output reg valid_out,
    output [7:0] dout    //SBox output
); 

wire [15:0] data_out;       // 16-bit data output from SRAM
reg [7:0] addr_reg;         // Register the address

// Register the address to align with SRAM read timing
always @(posedge clk or negedge reset) begin
    if (!reset)
        addr_reg <= 8'h0;
    else if (valid_in)
        addr_reg <= addr_in;
end

// Instantiate synchronous SRAM
srambank_64x4x16_6t122 sram (
    .clk    (clk),
    .ADDRESS(addr_reg[7:1]),    // Use registered address
    .wd     (16'h0000),         // Not writing, so set to 0
    .banksel(1'b1),             // Keep bank always enabled for reading
    .read   (valid_in),         // Enable read when input is valid
    .write  (1'b0),             // Never write from this module
    .dataout(data_out)
);

// Pipeline valid signal to match data timing
reg valid_pipe;
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        valid_pipe <= 1'b0;
        valid_out <= 1'b0;
    end else begin
        valid_pipe <= valid_in;
        valid_out <= valid_pipe;
    end
end

// Register dout to avoid undefined values
reg [7:0] dout_reg;
assign dout = dout_reg;

// Output logic with proper timing
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        dout_reg <= 8'b0;
    end else begin
        // Use registered address for byte selection
        dout_reg <= (addr_reg[0] == 1'b0) ? data_out[7:0] : data_out[15:8];
    end
end

// Optional debug display
// always @(posedge clk) begin
//     if (valid_out) begin
//         $display("At time %0t: data_out = %h", $time, data_out);
//     end
// end

endmodule