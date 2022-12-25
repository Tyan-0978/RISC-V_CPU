module stage4_memory (
    input CLOCK_50,
    input mem_read,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    input [2:0] funct3,
    output bubble,
    output [31:0] read_data,
    output o_SRAM_WE_N,
    output o_SRAM_CE_N,
    output o_SRAM_OE_N,
    output o_SRAM_LB_N,
    output o_SRAM_UB_N,
    inout [15:0] o_SRAM_DQ, 
    output [19:0] o_SRAM_ADDR
);
wire [15:0] read_data;
wire o_bubble;
wire SRAM_LB_N, SRAM_UB_N;
wire [19:0] addr;
wire [15:0] sram_read;

assign bubble = o_bubble;
assign read_data = o_read_register;
assign o_SRAM_WE_N = (mem_write) ? 1'b0 : 1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = SRAM_LB_N;
assign o_SRAM_UB_N = SRAM_UB_N;
assign o_SRAM_DQ = (mem_write) ? sram_write : 16'dz; 
assign o_SRAM_ADDR = (o_bubble) ? addr+1 : addr;
assign addr = address[19:0] << 1; 
assign sram_read = (!mem_write) ? o_SRAM_DQ : 16'd0;

data_memory mem0(
    .i_clk(CLOCK_50),
    .i_write_data(write_data),
    .i_mem_read(mem_read),
    .i_mem_write(mem_write),
    .i_funct3(funct3),
    .i_sram_read(sram_read),
    .o_bubble(o_bubble),
    .o_read_register(o_read_register),
    .o_LB_N(SRAM_LB_N),
    .o_UB_N(SRAM_UB_N),
    .o_sram_write(sram_write)
);
/*
always@ (posedge CLOCK_50 or negedge SW[0]) begin
    if(!SW[0]) begin
        bubble_r <= 0;
        read_register_r <= 32'd0;
    end
    else begin
        bubble_r <= bubble_w;
        read_register_r <= read_register_w;
    end
end
*/
endmodule
