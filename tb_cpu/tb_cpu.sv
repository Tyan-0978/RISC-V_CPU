// -----------------------------------------------------------------------------
// CPU testbench
// -----------------------------------------------------------------------------

`timescale 1ns/100ps

// tb module ---------------------------------------------------------
module tb;

localparam CLK = 10;
localparam HCLK = CLK/2;

logic rst_n, clk;
initial clk = 0;
always #HCLK clk = ~clk;

logic start;
logic [31:0] inst;
logic out_ecall;
logic out_ecall_data;

int f_inst;
logic [31:0] scan_inst;

cpu cpu0 (
    .i_rst_n(rst_n), .i_clk(clk), .i_start(start),
    .i_inst(inst),
    .o_ecall_ready(out_ecall),
    .o_ecall_data(out_ecall_data)
);

initial begin
    $fsdbDumpfile("wave_cpu.fsdb");
    $fsdbDumpvars(0, cpu0, "+mda");
    $fsdbDumpvars;

    // reset
    rst_n = 0;
    start = 0;
    inst = 0;
    f_inst = $fopen("instructions.txt", "r");
    #(5*CLK)
    rst_n = 1;
    #(20*CLK)

    $display("======================================================================");
    $display("Start CPU test");
    $display("======================================================================");

    @(negedge clk)
    start <= 1;
    while (!$feof(f_inst)) begin
	@(negedge clk)
        if (!cpu0.nop) begin
            $fscanf(f_inst, "%h", scan_inst);
	    inst <= scan_inst;
	end
    end

    $fclose(f_inst);
    //@(negedge clk)
    inst <= 0;
    repeat (10) @(negedge clk);

    $display("======================================================================");
    $display("Test finished");
    $display("======================================================================");

    $finish;
end

initial begin
    #(100*CLK)
    $display("======================================================================");
    $display("Too slow, abort");
    $display("======================================================================");
    $finish;
end

endmodule
