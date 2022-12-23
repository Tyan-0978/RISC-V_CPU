// -----------------------------------------------------------------------------
// adder / subtractor module
// -----------------------------------------------------------------------------

module int_add_sub (
    input  i_mode, // 0: add, 1: subtract
    input  [31:0] i_a,
    input  [31:0] i_b,
    output [31:0] o_result
);

wire [31:0] op_b;
wire [31:0] out;

assign op_b = i_b ^ {32{i_mode}};
assign out = i_a + op_b + i_mode;
assign o_result = out;

endmodule
