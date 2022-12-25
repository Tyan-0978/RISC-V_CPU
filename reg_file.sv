module reg_file(
    input reg_write;
    input [4:0] write_rs;
    output [31:0] rs1_data, rs2_data;
    input [31:0] write_data;
    input [4:0] read_rs1, read_rs2;
);

logic [0:4] register [31:0]
assign register[0] = 0;
assign rs1_data = register[read_rs1];
assign rs2_data = register[read_rs2];
always_comb begin
    register[write_rs] = write_data;
end

endmodule