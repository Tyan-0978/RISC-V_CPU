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
reg  [31:0] rs1_data, next_rs1_data;
reg  [31:0] rs2_data, next_rs2_data;

assign o_rs1_data = rs1_data;
assign o_rs2_data = rs2_data;

always_comb begin
    // next output
    next_rs1_data = (i_write_rd == i_read_rs1) ? 
                     i_write_data : registers[i_read_rs1];
    next_rs2_data = (i_write_rd == i_read_rs2) ? 
                     i_write_data : registers[i_read_rs2];
    next_rs2_data = registers[i_read_rs2];
    // next registers
    next_registers[0] = 0; // reserved
    for (int i = 1; i < 32; i++) begin
        if (i_write_rd == i) next_registers[i] = i_write_data;
        else                 next_registers[i] = registers[i];
    end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        for (int i = 0; i < 32; i++) registers[i] <= 0;
	rs1_data <= 0;
	rs2_data <= 0;
    end else begin
        for (int i = 0; i < 32; i++) registers[i] <= next_registers[i];
	rs1_data <= next_rs1_data;
	rs2_data <= next_rs2_data;
    end
end

endmodule
