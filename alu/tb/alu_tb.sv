// -----------------------------------------------------------------------------
// ALU top module testbench
// -----------------------------------------------------------------------------

`timescale 1ns/100ps

// input random class ------------------------------------------------
class rand_in;
    rand bit signed [31:0] a;
    rand bit signed [31:0] b;

    constraint c {
        a >= -1000; a <= 1000;
        b >= -1000; b <= 1000;
    }
endclass

// tb module ---------------------------------------------------------
module tb;

localparam CLK = 10;
localparam HCLK = CLK/2;

// number of tests for each mode
localparam num_tests = 100;

// operation modes (i_op_mode)
localparam IDLE        = 0;
localparam LOGIC       = 1;
localparam SHIFT       = 2;
localparam COMPARE     = 3;
localparam INT_ADD_SUB = 4;
localparam INT_MUL     = 5;
localparam INT_DIV     = 6;

// test control
logic test_int_add_sub;
logic test_int_mul;
logic test_int_div;

logic rst_n, clk;
initial clk = 0;
always #HCLK clk = ~clk;

logic [2:0] op_mode;
logic [1:0] func_op;
logic       fp_mode;
logic       in_stall;
logic signed [31:0] a, b;
logic signed [31:0] result;
logic out_stall;

integer expected;
integer err_count;
rand_in rin;

alu alu0 (
    .i_rst_n(rst_n),
    .i_clk(clk),
    .i_op_mode(op_mode),
    .i_func_op(func_op),
    .i_fp_mode(fp_mode),
    .i_stall(in_stall),
    .i_a(a),
    .i_b(b),
    .o_result(result),
    .o_stall(out_stall)
);

initial begin
    $fsdbDumpfile("test_int_mul.fsdb");
    $fsdbDumpvars;

    // test settings
    test_int_add_sub = 0;
    test_int_mul = 0;
    test_int_div = 0;

    // reset
    rst_n = 0;
    op_mode = IDLE;
    func_op = 0;
    fp_mode = 0; // will not change
    in_stall = 0;
    a = 0; b = 0;
    rin = new();
    #(5*CLK)
    rst_n = 1;
    #(5*CLK)

    if (test_int_add_sub) begin
	$display("======================================================================");
	$display("Start integer addition test");
	$display("======================================================================");
	err_count = 0;
	op_mode = INT_ADD_SUB;
	func_op = 3'b000; // add
	for (int i = 1; i <= num_tests; i++) begin
	    rin.randomize();
	    @(negedge clk)
	    a <= rin.a;
	    b <= rin.b;

	    @(negedge clk)
	    expected = a + b;
	    if (result !== expected) begin
		$display("Error on test %0d", i);
		$display("a = %d, b = %d, result = %d, expected = %d" , a, b, result, expected);
		$display("");
		err_count = err_count + 1;
	    end
	end
	$display("======================================================================");
	$display("Test finished, %0d / %0d passed.", num_tests - err_count, num_tests);
	$display("======================================================================");

	$display("======================================================================");
	$display("Start integer subtraction test");
	$display("======================================================================");
	err_count = 0;
	op_mode = INT_ADD_SUB;
	func_op = 3'b001; // sub
	for (int i = 1; i <= num_tests; i++) begin
	    rin.randomize();
	    @(negedge clk)
	    a <= rin.a;
	    b <= rin.b;

	    @(negedge clk)
	    expected = a - b;
	    if (result !== expected) begin
		$display("Error on test %0d", i);
		$display("a = %d, b = %d, result = %d, expected = %d" , a, b, result, expected);
		$display("");
		err_count = err_count + 1;
	    end
	end
	$display("======================================================================");
	$display("Test finished, %0d / %0d passed.", num_tests - err_count, num_tests);
	$display("======================================================================");
    end

    if (test_int_mul) begin
	$display("======================================================================");
	$display("Start integer multiplication test");
	$display("======================================================================");
	err_count = 0;
	for (int i = 1; i <= num_tests; i++) begin
	    rin.randomize();
	    @(negedge clk)
	    op_mode <= INT_MUL;
	    a <= rin.a;
	    b <= rin.b;

	    @(negedge clk)
	    //op_mode <= IDLE;
	    expected = a * b;

	    while (out_stall) @(negedge clk);
	    if (result !== expected) begin
		$display("Error on test %0d", i);
		$display("a = %d, b = %d, result = %d, expected = %d" , a, b, result, expected);
		$display("");
		err_count = err_count + 1;
	    end
	end
	$display("======================================================================");
	$display("Test finished, %0d / %0d passed.", num_tests - err_count, num_tests);
	$display("======================================================================");
    end

    $finish;
end


endmodule
