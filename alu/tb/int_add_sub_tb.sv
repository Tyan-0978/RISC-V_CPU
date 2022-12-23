// -----------------------------------------------------------------------------
// int_add_sub testbench
// -----------------------------------------------------------------------------

`timescale 1ns/100ps
`include "../int_add_sub.v"

// input random class ------------------------------------------------
class rand_in;
    rand bit mode;
    rand bit [31:0] a;
    rand bit [31:0] b;

    /*
    constraint c {
        a >= 0; a <= 10;
        b >= 0; b <= 10;
    }
    */
endclass

// tb module ---------------------------------------------------------
module tb;

localparam CLK = 10;
localparam HCLK = CLK/2;

// number of tests
localparam num_tests = 100;

logic rst_n, clk;
initial clk = 0;
always #HCLK clk = ~clk;

logic mode;
logic signed [31:0] a, b;
logic signed [31:0] result;

integer expected;
integer err_count;
rand_in rin;

int_add_sub m0 (
    .i_mode(mode),
    .i_a(a),
    .i_b(b),
    .o_result(result)
);

initial begin
    $fsdbDumpfile("test_int_add_sub.fsdb");
    $fsdbDumpvars(0);

    rst_n = 0;
    err_count = 0;
    rin = new();
    #(5*CLK)
    rst_n = 1;

    for (int i = 1; i <= num_tests; i++) begin
        @(negedge clk);
        rin.randomize();
        mode <= rin.mode;
        a <= rin.a;
        b <= rin.b;

	@(posedge clk);
        if (rin.mode == 0) begin
            expected = rin.a + rin.b;
        end
        else begin
            expected = rin.a - rin.b;
        end

        if (result !== expected) begin
            $display("Error on test %0d", i);
            $display("a = %d, b = %d, mode = %d, result = %d, expected = %d" , a, b, mode, result, expected);
	    $display("");
            err_count = err_count + 1;
        end
    end

    $display("================================================================================");
    $display("Test finished, %0d / %0d passed.", num_tests - err_count, num_tests);
    $display("================================================================================");
    $finish;
end

endmodule
