// -----------------------------------------------------------------------------
// floating point adder / subtractor module
// -----------------------------------------------------------------------------

module int_add_sub (
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
// table for op_mode:
// a_sign  b_sign  i_mode  result
// 0       0       0       a + b
// 0       0       1       a - b
// 0       1       0       a - b
// 0       1       1       a + b
// 1       0       0       - (a - b)
// 1       0       1       - (a + b)
// 1       1       0       - (a + b)
// 1       1       1       - (a - b)
wire op_mode, extra_sign;

wire [23:0] a_op, b_op;
reg  [23:0] a_op_shift, b_op_shift;
wire [24:0] op_sum, op_diff;
reg  [24:0] op_result;

wire signed [8:0] exp_diff;
wire        [7:0] larger_exp;

wire [23:0] rm_zeros_diff;
wire [7:0]  rm_zeros_num;

// output
reg         out_sign;
reg  [7:0]  out_exp;
reg  [22:0] out_frac;

// modules -----------------------------------------------------------
shift_sub s0 (
    .i_diff(op_diff[23:0]), 
    .o_shift_diff(rm_zeros_diff), 
    .o_shift_num(rm_zeros_num)
);

// wire assignments --------------------------------------------------
// FP decoding
assign a_sign = i_a[31];
assign b_sign = i_b[31];
assign a_exp  = i_a[30:23];
assign b_exp  = i_b[30:23];
assign a_frac = i_a[22:0];
assign b_frac = i_b[22:0];

// computation
assign op_mode = a_sign ^ b_sign ^ i_mode;

assign a_op = {1'b1, a_frac};
assign b_op = {1'b1, b_frac};
assign exp_diff = a_exp - b_exp;
assign larger_exp = (exp_diff[8]) ? b_exp : a_exp;
assign op_sum  = a_op_shift + b_op_shift;
assign op_diff = a_op_shift - b_op_shift;

// output pin
assign o_result = {out_sign, out_exp, out_frac};

// always block ------------------------------------------------------
always @(*) begin
    // compare exponent of a, b to decide which should be shifted
    if (exp_diff[8]) begin // exp_b > exp_a, shift a
        a_op_shift = a_op >> exp_diff[7:0];
        b_op_shift = b_op;
    end
    else begin // exp_a >= exp_b, shift b
        a_op_shift = a_op;
        b_op_shift = b_op >> exp_diff[7:0];
    end

    // operation result
    if (op_mode) begin // subtract
        op_result = op_diff;
    end
    else begin // add
        op_result = op_sum;
    end

    // output
    if (op_mode) begin // subtract
        out_sign = a_sign ^ op_diff[24];
	if (rm_zeros_num > larger_exp) begin // too small; becomes 0
	    out_exp = 0;
	    out_frac = 0;
	end
	else begin
	    out_exp = larger_exp - rm_zeros_num;
	    out_frac = rm_zeros_diff[22:0];
	end
    end
    else begin // add
        out_sign = a_sign;
	if (op_sum[24]) begin // carry
	    out_exp  = larger_exp + 1;
	    out_frac = op_sum[23:1];
	end
	else begin
	    out_exp  = larger_exp;
	    out_frac = op_sum[22:0];
	end
    end
end

endmodule

// -----------------------------------------------------------------------------
// module for shifting subtraction result
// -----------------------------------------------------------------------------

module shift_sub (
    input  [23:0] i_diff,
    output [23:0] o_shift_diff,
    output [4:0]  o_shift_num
);

integer x;

// wires & registers -------------------------------------------------
reg  [11:0] or_tree_1;
reg  [5:0]  or_tree_2;
reg  [2:0]  or_tree_3;

reg  [1:0]  or_3_sel_2;
reg  [3:0]  or_3_sel_1;
reg  [7:0]  or_3_sel_0;

reg  [1:0]  or_2_sel_1;
reg  [3:0]  or_2_sel_0;

reg  [1:0]  or_1_sel_0;

reg  [23:0] shift_layer [0:3];
reg  [4:0]  shift_num;

// wire assignments --------------------------------------------------
assign o_shift_diff = shift_layer[0];
assign o_shift_num = shift_num;

// always block ------------------------------------------------------
always @(*) begin
    for (x = 0; x <= 11; x = x + 1) begin
        or_tree_1[x] = i_diff[2*x] | i_diff[2*x+1];
    end
    for (x = 0; x <= 5; x = x + 1) begin
        or_tree_2[x] = or_tree_1[2*x] | or_tree_1[2*x+1];
    end
    for (x = 0; x <= 2; x = x + 1) begin
        or_tree_3[x] = or_tree_2[2*x] | or_tree_2[2*x+1];
    end

    // OR tree layer 3
    case (or_tree_3) 
        3'b1xx: begin
	    shift_num[4:3] = 2'b00;
	    shift_layer[3] = i_diff;
	    or_3_sel_2 = or_tree_2[5:4];
	    or_3_sel_1 = or_tree_1[11:8];
	    or_3_sel_0 = i_diff[24:17];
	end
        3'b01x: begin
	    shift_num[4:3] = 2'b01; // 8
	    shift_layer[3] = i_diff << 8;
	    or_3_sel_2 = or_tree_2[3:2];
	    or_3_sel_1 = or_tree_1[7:4];
	    or_3_sel_0 = i_diff[16:9];
	end
        3'b001: begin
	    shift_num[4:3] = 2'b10; // 16
	    shift_layer[3] = i_diff << 16;
	    or_3_sel_2 = or_tree_2[1:0];
	    or_3_sel_1 = or_tree_1[3:0];
	    or_3_sel_0 = i_diff[8:1];
	end
        default: begin // 0
	    shift_num[4:3] = 2'b11; // 24
	    shift_layer[3] = 0;
	    or_3_sel_2 = 0;
	    or_3_sel_1 = 0;
	    or_3_sel_0 = 0;
	end
    endcase

    // OR tree layer 2
    case (or_3_sel_2)
        2'b1x: begin
	    shift_num[2] = 1;
	    shift_layer[2] = shift_layer[3];
	    or_2_sel_1 = or_3_sel_1[3:2];
	    or_2_sel_0 = or_3_sel_0[7:4];
	end
	2'b01: begin
	    shift_num[2] = 0;
	    shift_layer[2] = shift_layer[3] << 4;
	    or_2_sel_1 = or_3_sel_1[1:0];
	    or_2_sel_0 = or_3_sel_0[3:0];
	end
	default: begin // 0
	    shift_num[2] = 0;
	    shift_layer[2] = shift_layer[3];
	    or_2_sel_1 = 0;
	    or_2_sel_0 = 0;
	end
    endcase

    // OR tree layer 1
    case (or_2_sel_1)
        2'b1x: begin
	    shift_num[1] = 1;
	    shift_layer[1] = shift_layer[2];
	    or_1_sel_0 = or_2_sel_0[3:2];
	end
	2'b01: begin
	    shift_num[1] = 0;
	    shift_layer[1] = shift_layer[2] << 2;
	    or_1_sel_0 = or_2_sel_0[1:0];
	end
	default: begin // 0
	    shift_num[1] = 0;
	    shift_layer[1] = shift_layer[2];
	    or_1_sel_0 = 0;
	end
    endcase

    // OR tree layer 0
    case (or_1_sel_0)
        2'b1x: begin
	    shift_num[0] = 1;
	    shift_layer[0] = shift_layer[1];
	end
	2'b01: begin
	    shift_num[0] = 0;
	    shift_layer[0] = shift_layer[1] << 1;
	end
	default: begin // 0
	    shift_num[0] = 0;
	    shift_layer[0] = shift_layer[0];
	end
    endcase
end

endmodule
