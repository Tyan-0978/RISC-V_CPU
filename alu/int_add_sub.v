// -----------------------------------------------------------------------------
// adder / subtractor module
// -----------------------------------------------------------------------------

module int_add_sub (
    input  i_mode, // 0: add, 1: subtract
    input  signed [31:0] i_a,
    input  signed [31:0] i_b,
    output signed [31:0] o_result
);

reg  signed [31:0] op_b;
reg  signed [31:0] out;

assign o_result = out;

always @ (*) begin
    op_b = i_b ^ i_mode;
    out = i_a + op_b + i_mode;
end

endmodule
