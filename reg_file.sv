module reg_file(
    input  i_rst_n,
    input  i_clk,
    input  i_reg_write,
    input  [ 4:0] i_write_rd,
    input  [31:0] i_write_data,
    input  [ 4:0] i_read_rs1,
    input  [ 4:0] i_read_rs2,
    output [31:0] o_rs1_data,
    output [31:0] o_rs2_data
);

reg  [31:0] registers [0:31];
reg  [31:0] next_registers [0:31];

assign rs1_data = registers[read_rs1];
assign rs2_data = registers[read_rs2];

always_comb begin
    // next registers
    next_registers[0] = 0; // reserved
    for (int i = 1; i < 32; i++) begin
        if (i_write_rd == i) next_registers[i] = i_write_data;
        else                 next_registers[i] = registers[i];
    end
end

always_ff begin
    if (!i_rst_n) begin
        for (int i = 0; i < 32; i++) registers[i] <= 0;
    end else begin
        for (int i = 0; i < 32; i++) registers[i] <= next_registers[i];
    end
end

endmodule
