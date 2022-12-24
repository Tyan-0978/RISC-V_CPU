// -----------------------------------------------------------------------------
// ALU top module
// -----------------------------------------------------------------------------

module alu (
    input  i_rst_n,
    input  i_clk,
    // control
    input  [ 2:0] i_op_mode, // operation modes
    input  [ 2:0] i_func_op, // functional options
    input         i_fp_mode, // 0: integer, 1: FP
    input         i_stall,
    output        o_stall, // non-blocking
    // operands & result
    input  [31:0] i_a,
    input  [31:0] i_b,
    output [31:0] o_result // blocking; only change at posedge clk
);

// operation modes (i_op_mode)
localparam IDLE        = 0;
localparam LOGIC       = 1;
localparam SHIFT       = 2;
localparam COMPARE     = 3;
localparam INT_ADD_SUB = 4;
localparam INT_MUL     = 5;
localparam INT_DIV     = 6;

// registers & wires -------------------------------------------------
// sub-module ports
wire [ 1:0] logic_i_mode; // 0: AND, 1: OR, 2: XOR
wire [31:0] logic_i_a, logic_i_b;
wire [31:0] logic_o_result;

wire shift_i_mode; // 0: logical, 1: arithmetic (keep sign)
wire shift_i_direction; // 0: left, 1: right
wire [31:0] shift_i_a, shift_i_b;
wire [31:0] shift_o_result;

wire comp_i_eq;   // 0: (<, >, !=), 1: (<=, >=, ==)
wire comp_i_mode; // 00: <, 01: >, 1x: ==
wire [31:0] comp_i_a, comp_i_b;
wire [31:0] comp_o_result;

wire int_add_sub_i_mode; // 0: add, 1: subtract
wire [31:0] int_add_sub_i_a, int_add_sub_i_b;
wire [31:0] int_add_sub_o_result;

wire        int_mul_i_valid;
wire [31:0] int_mul_i_a, int_mul_i_b;
wire        int_mul_o_valid;
wire [31:0] int_mul_o_result;

wire        int_div_i_valid;
wire [31:0] int_div_i_a, int_div_i_b;
wire        int_div_o_valid;
wire [31:0] int_div_o_quotient, int_div_o_remainder;

// control signals
wire mul_stall, div_stall;

// output
reg  [31:0] result_select;
reg  [31:0] result, next_result;

// sub-modules -------------------------------------------------------
logic logic0 (
    .i_mode(logic_i_mode), .i_a(logic_i_a), .i_b(logic_i_b), 
    .o_result(logic_o_result)
);
shift shift0 (
    .i_mode(shift_i_mode), .i_direction(shift_i_direction),
    .i_a(shift_i_a), .i_b(shift_i_b), .o_result(shift_o_result)
);
comp comp0 (
    .i_eq(comp_i_eq), .i_mode(comp_i_mode),
    .i_a(comp_i_a), .i_b(comp_i_b), .o_result(comp_o_result)
);
int_add_sub int_add_sub0(
    .i_mode(int_add_sub_i_mode), .i_a(int_add_sub_i_a), .i_b(int_add_sub_i_b), 
    .o_result(int_add_sub_o_result)
);
int_mul int_mul0 (
    .i_rst_n(i_rst_n), .i_clk(i_clk),
    .i_valid(int_mul_i_valid), .i_a(int_mul_i_a), .i_b(int_mul_i_b), 
    .o_valid(int_mul_o_valid), .o_result(int_mul_o_result)
);
int_div int_div0 (
    .i_rst_n(i_rst_n), .i_clk(i_clk),
    .i_valid(int_div_i_valid), .i_a(int_div_i_a), .i_b(int_div_i_b), 
    .o_valid(int_div_o_valid), 
    .o_quotient(int_div_o_quotient),.o_remainder(int_div_o_remainder)
);

// wire assignments --------------------------------------------------
// sub-module input
assign logic_i_mode = i_func_op[1:0];
assign logic_i_a = i_a;
assign logic_i_b = i_b;

assign shift_i_mode = i_func_op[0];
assign shift_i_direction = i_func_op[1];
assign shift_i_a = i_a;
assign shift_i_b = i_b;

assign comp_i_eq = i_func_op[2];
assign comp_i_mode = i_func_op[1:0];
assign comp_i_a = i_a;
assign comp_i_b = i_b;

assign int_add_sub_i_mode = i_func_op[0];
assign int_add_sub_i_a = i_a;
assign int_add_sub_i_b = i_b;

assign int_mul_i_a = i_a;
assign int_mul_i_b = i_b;

assign int_div_i_a = i_a;
assign int_div_i_b = i_b;

// output stall signal
assign mul_stall = (i_op_mode == INT_MUL && !int_mul_o_valid);
assign div_stall = (i_op_mode == INT_DIV && !int_div_o_valid);
assign o_stall = (mul_stall | div_stall);

assign o_result = result;

// combinational always block ----------------------------------------
always @(*) begin
    // result selection
    case (i_op_mode)
        IDLE:        result_select = i_a;
	LOGIC:       result_select = logic_o_result;
	SHIFT:       result_select = shift_o_result;
	COMPARE:     result_select = comp_o_result;
	INT_ADD_SUB: result_select = int_add_sub_o_result;
	INT_MUL:     result_select = int_mul_o_result;
	INT_DIV:     result_select = int_div_o_result;
	default:     result_select = i_a;
    endcase

    // next result
    if (i_stall) next_result = result; // do not change output
    else         next_result = result_select;
end

// sequential always block -------------------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        result <= 0;
    end else begin
        result <= next_result;
    end
end

endmodule
