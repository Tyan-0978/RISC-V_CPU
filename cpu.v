// -----------------------------------------------------------------------------
// RISC-V CPU Core
// -----------------------------------------------------------------------------

module cpu (
    input  i_rst_n,
    input  i_clk,
    // TODO: ecall pins
    // TODO: memory I/O pins
);

// wires & registers -------------------------------------------------
// CPU top control
wire stall_all;

// program counter
reg  [10:0] pc, next_pc;

// instruction decoding stage
wire [31:0] id_i_inst_data;
reg  [4:0]  id_o_rd, id_o_rs1, id_o_rs2, id_rd, id_rs1, id_rs2;
reg  [31:0] id_imm, id_o_imm;
reg  [2:0]  id_funct3, id_o_funct3;
reg  id_alusrc, id_mem_treg, id_reg_write;
reg  id_o_alusrc, id_o_mem_to_reg, id_o_reg_write;
reg  id_mem_read, id_mem_write, id_branch;
reg  id_o_mem_read, id_o_mem_write, id_o_branch;
reg  [2:0] id_op_mode, id_func_op, id_o_op_mode, id_o_func_op;
reg  id_fp_mode, id_o_fp_mode;

// register file stage

// ALU stage
wire [2:0] alu_i_op_mode;
wire [2:0] alu_i_func_op;
wire alu_i_fp_mode;
wire alu_i_stall, alu_o_stall;
wire [31:0] alu_i_a, alu_i_b, alu_o_result;

// data memory stage

// -------------------------------------------------------------------
// CPU top control
// -------------------------------------------------------------------
assign stall_all = (alu_o_stall);

// -------------------------------------------------------------------
// program counter stage
// -------------------------------------------------------------------
always @(*) begin
    // TODO: next_pc logic
    if () begin // branch or jump
        next_pc = ?;
    end else begin
        next_pc = pc + 1;
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        pc <= 0;
    end else begin
        pc <= next_pc;
    end
end

// -------------------------------------------------------------------
// instruction decoding stage
// -------------------------------------------------------------------
// TODO: instruction memory
inst_dec inst_dec0 (
    .i_inst_data(id_i_inst_data),
    .o_rd(id_o_rd), .o_rs1(id_o_rs1), .o_rs2(id_o_rs2),
    .o_imm(id_o_imm), .o_funct3(id_o_funct3),
    .o_alusrc(id_o_alusrc), 
    .o_mem_to_reg(id_o_mem_to_reg), 
    .o_reg_write(id_o_reg_write),
    .o_mem_read(id_o_mem_read), 
    .o_mem_write(id_o_mem_write),
    .o_branch(id_o_branch),
    .o_op_mode(id_o_op_mode), .o_func_op(id_o_func_op), 
    .o_fp_mode(id_o_fp_mode)
);
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        id_rd <= 0; 
        id_rs1 <= 0;
        id_rs2 <= 0;
        id_imm <= 0;
        id_funct3 <= 0;
        id_alusrc <= 0;
        id_mem_to_reg <= 0;
        id_reg_write <= 0;
        id_mem_read <= 0;
        id_mem_write <= 0;
        id_branch <= 0;
        id_op_mode <= 0;
        id_func_op <= 0;
        id_fp_mode <= 0;
    end else begin
        id_rd <= id_o_rd; 
        id_rs1 <= id_o_rs1;
        id_rs2 <= id_o_rs2;
        id_imm <= id_o_imm;
        id_funct3 <= id_o_funct3;
        id_alusrc <= id_o_alusrc;
        id_mem_to_reg <= id_o_mem_to_reg;
        id_reg_write <= id_o_reg_write;
        id_mem_read <= id_o_mem_read;
        id_mem_write <= id_o_mem_write;
        id_branch <= id_o_branch;
        id_op_mode <= id_o_op_mode;
        id_func_op <= id_o_func_op;
        id_fp_mode <= id_o_fp_mode;
    end
end

// -------------------------------------------------------------------
// register file stage 
// -------------------------------------------------------------------
// TODO

// -------------------------------------------------------------------
// ALU stage 
// -------------------------------------------------------------------
// TODO: ALU control
alu alu0 (
    .i_rst_n(i_rst_n), .i_clk(i_clk),
    .i_op_mode(alu_i_op_mode), .i_func_op(alu_i_func_op), 
    .i_fp_mode(alu_i_fp_mode), .i_stall(alu_i_stall),
    .i_a(alu_i_a), .i_b(alu_i_b),
    .o_result(alu_o_result),
    .o_stall(alu_o_stall)
);

// -------------------------------------------------------------------
// data memory stage
// -------------------------------------------------------------------
// TODO

endmodule
