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

cpu cpu0 (
    .i_rst_n(rst_n), .i_clk(clk), .i_start(start),
    .id_i_inst_data(inst),
    .o_ecall_ready(),
    .o_ecall_data()
);

initial begin
    $fsdbDumpfile("wave_cpu.fsdb");
    $fsdbDumpvars(0,cpu0,"+mda");
    $fsdbDumpvars;

    // reset
    rst_n = 0;
    start = 0;
    inst = 0;
    #(5*CLK)
    rst_n = 1;
    #(5*CLK)

    $display("======================================================================");
    $display("Start CPU test");
    $display("======================================================================");

    @(negedge clk)
    start <= 1;
    inst <= 32'h00100593;
    @(negedge clk)
    inst <= 32'h00200613;
    @(negedge clk)
    inst <= 32'h00300693;
    @(negedge clk)
    inst <= 32'h00400713;
    @(negedge clk)
    inst <= 32'h00500793;
    @(negedge clk)
    inst <= 32'h00C58833;
    @(negedge clk)
    inst <= 32'h00D608B3;

    repeat (10) @(negedge clk);

    $display("======================================================================");
    $display("Test finished");
    $display("======================================================================");

    $finish;
end


endmodule
