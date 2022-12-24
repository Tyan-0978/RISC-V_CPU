// -----------------------------------------------------------------------------
// int_mul testbench
// -----------------------------------------------------------------------------

`timescale 1ns/100ps
`include "../int_mul.v"

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

// number of tests
localparam num_tests = 100;

logic rst_n, clk, in_valid;
initial clk = 0;
always #HCLK clk = ~clk;

logic signed [31:0] a, b;
logic signed [31:0] result;
logic out_valid;

integer expected;
integer err_count;
rand_in rin;

int_mul m0 (
    .i_rst_n(rst_n),
    .i_clk(clk),
    .i_valid(in_valid),
    .i_a(a),
    .i_b(b),
    .o_result(result),
    .o_valid(out_valid)
);

initial begin
    $fsdbDumpfile("test_int_mul.fsdb");
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
        expected = a * b;

        @(posedge out_valid);
	while (!out_valid) @(negedge clk);
        if (result !== expected) begin
            $display("Error on test %0d", i);
            $display("a = %d, b = %d, result = %d, expected = %d" , a, b, result, expected);
	    $display("");
            err_count = err_count + 1;
        end
        //@(negedge clk);
    end

    $display("================================================================================");
    $display("Test finished, %0d / %0d passed.", num_tests - err_count, num_tests);
    $display("================================================================================");
    $finish;
end

initial begin
    #(10000*CLK);
    $display("================================================================================");
    $display("Too slow, abort");
    $display("================================================================================");
    $finish;
end

endmodule
