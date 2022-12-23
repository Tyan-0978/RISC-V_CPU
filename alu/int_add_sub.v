// -----------------------------------------------------------------------------
// adder / subtractor module
// -----------------------------------------------------------------------------

module int_add_sub (
    input  i_mode, // 0: add, 1: subtract
    input  signed [31:0] i_a,
    input  signed [31:0] i_b,
    output signed [31:0] o_result
);

wire signed [31:0] op_b;
wire signed [31:0] out;

assign op_b = i_b ^ i_mode;
assign out = i_a + op_b + i_mode;
assign o_result = out;

endmodule
