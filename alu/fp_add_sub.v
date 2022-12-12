// -----------------------------------------------------------------------------
// floating point adder / subtractor module
// -----------------------------------------------------------------------------

module int_add_sub ( // ----------------------------------------------
    input  i_mode, // 0: add, 1: subtract
    input  [31:0] i_a,
    input  [31:0] i_b,
    output [31:0] o_result
);

// wires & registers -------------------------------------------------
// FP decoding
wire        a_sign, b_sign;
wire [7:0]  a_exp , b_exp;
wire [22:0] a_frac, b_frac;

// computation
wire        [23:0] a_op, b_op;
wire signed [8:0]  exp_diff;
wire        [24:0] sum;
wire 
// output
wire signed [31:0] out;

// wire assignments --------------------------------------------------
// FP decoding
assign a_sign = i_a[31];
assign b_sign = i_b[31];
assign a_exp  = i_a[30:23];
assign b_exp  = i_b[30:23];
assign a_frac = i_a[22:0];
assign b_frac = i_b[22:0];

// computation
assign a_op = {a_sign, a_frac};
assign b_op = i_mode ^ {b_sign, b_frac};
assign exp_diff = a_exp - b_exp;

// output
assign o_result = out;

endmodule // ---------------------------------------------------------
