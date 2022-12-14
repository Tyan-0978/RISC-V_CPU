// -----------------------------------------------------------------------------
// int_div testbench
// -----------------------------------------------------------------------------

`timescale 1ns/100ps
`include "../int_div.v"

// input random class ------------------------------------------------
class rand_in;
    rand bit signed [31:0] a;
    rand bit signed [31:0] b;

    constraint c {
        a >= 0; a <= 1000000000;
        b >= 0; b <= 1000;
    }
endclass

// tb module ---------------------------------------------------------
module tb;

localparam CLK = 10;
localparam HCLK = CLK/2;

// number of tests
localparam num_tests = 1000;

logic rst_n, clk, in_valid;
initial clk = 0;
always #HCLK clk = ~clk;

logic signed [31:0] a, b;
logic signed [31:0] quotient, remainder;
logic out_valid;

integer ans_q, ans_r;
integer err_count;
rand_in rin;

int_div m0 (
    .i_rst_n(rst_n),
    .i_clk(clk),
    .i_valid(in_valid),
    .i_a(a),
    .i_b(b),
    .o_valid(out_valid),
    .o_quotient(quotient),
    .o_remainder(remainder)
);

initial begin
    $fsdbDumpfile("test_int_div.fsdb");
    $fsdbDumpvars;

    rst_n = 0;
    in_valid = 0;
    err_count = 0;
    rin = new();
    #(5*CLK)
    rst_n = 1;
    #(5*CLK)

    for (int i = 1; i <= num_tests; i++) begin
        rin.randomize();
        @(negedge clk)
        a <= rin.a;
        b <= rin.b;
        in_valid <= 1;
        @(negedge clk)
        in_valid <= 0;
        ans_q = a / b;
	ans_r = a % b;

        @(posedge out_valid);
	while (!out_valid) @(negedge clk);
        if ((quotient !== ans_q) || (remainder !== ans_r)) begin
            $display("Error on test %0d", i);
            $display("a = %d, b = %d, quotient = %d, expected = %d" , a, b, quotient, ans_q);
            $display("a = %d, b = %d, remainder = %d, expected = %d" , a, b, remainder, ans_r);
	    $display("");
            err_count = err_count + 1;
        end
    end

    $display("================================================================================");
    $display("Test finished, %0d / %0d passed.", num_tests - err_count, num_tests);
    $display("================================================================================");
    $finish;
end

initial begin
    #(100000*CLK);
    $display("================================================================================");
    $display("Too slow, abort");
    $display("================================================================================");
    $finish;
end

endmodule
