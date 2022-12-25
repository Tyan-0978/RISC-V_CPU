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
reg  id_alusrc, id_mem_to_reg, id_reg_write;
reg  id_o_alusrc, id_o_mem_to_reg, id_o_reg_write;
reg  id_mem_read, id_mem_write, id_branch;
reg  id_o_mem_read, id_o_mem_write, id_o_branch;
reg  [2:0] id_op_mode, id_func_op, id_o_op_mode, id_o_func_op;
reg  id_fp_mode, id_o_fp_mode;

// register file stage
wire rf_i_reg_write,
wire [ 4:0] rf_i_write_rd;
wire [31:0] rf_i_write_data;
wire [ 4:0] rf_i_read_rs1;
wire [ 4:0] rf_i_read_rs2;
wire [31:0] rf_o_rs1_data;
wire [31:0] rf_o_rs2_data;

reg  [31:0] rf_imm;
reg  [2:0]  rf_funct3;
reg  rf_alusrc, rf_mem_to_reg, rf_reg_write;
reg  rf_mem_read, rf_mem_write, rf_branch;
reg  [2:0] rf_op_mode, rf_func_op;
reg  rf_fp_mode;

// ALU stage
wire [2:0] alu_i_op_mode;
wire [2:0] alu_i_func_op;
wire alu_i_fp_mode;
wire alu_i_stall, alu_o_stall;
wire [31:0] alu_i_a, alu_i_b, alu_o_result;
// TODO: branch result

reg  [2:0] alu_funct3;
reg  alu_mem_to_reg, alu_reg_write;
reg  alu_mem_read, alu_mem_write;

// data memory stage


reg  dmm_mem_to_reg, dmm_reg_write;

// write back stage

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
assign rf_i_reg_write = id_reg_write;
assign rf_i_write_rd = // TODO: connect from write back stage
assign rf_i_write_data = // TODO: connect from write back stage
assign i_read_rs1 = id_rs1;
assign i_read_rs2 = id_rs2;

reg_file reg_file0 (
    .i_rst_n(i_rst_n), .i_clk(i_clk),
    .i_reg_write(rf_i_reg_write),
    .i_write_rd(rf_i_write_rd), .i_write_data(rf_i_write_data),
    .i_read_rs1(rf_i_read_rs1), .i_read_rs2(rf_i_read_rs2),
    .o_rs1_data(rf_o_rs1_data), .o_rs2_data(rf_o_rs2_data)
);

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        rf_imm <= 0;
        rf_funct3 <= 0;
        rf_alusrc <= 0;
        rf_mem_to_reg <= 0;
        rf_reg_write <= 0;
        rf_mem_read <= 0;
        rf_mem_write <= 0;
        rf_branch <= 0;
        rf_op_mode <= 0;
        rf_func_op <= 0;
        rf_fp_mode <= 0;
    end else begin
        rf_imm <= id_imm;
        rf_funct3 <= id_funct3;
        rf_alusrc <= id_alusrc;
        rf_mem_to_reg <= id_mem_to_reg;
        rf_reg_write <= id_reg_write;
        rf_mem_read <= id_mem_read;
        rf_mem_write <= id_mem_write;
        rf_branch <= id_branch;
        rf_op_mode <= id_op_mode;
        rf_func_op <= id_func_op;
        rf_fp_mode <= id_fp_mode;
    end
end

// -------------------------------------------------------------------
// ALU stage 
// -------------------------------------------------------------------
assign alu_i_op_mode = rf_op_mode;
assign alu_i_func_op = rf_func_op;
assign alu_i_fp_mode = rf_fp_mode;
assign alu_i_stall = // TODO
assign alu_i_a = rf_o_rs1_data;
assign alu_i_b = (rf_alusrc) ? rf_imm : rf_o_rs2_data;

alu alu0 (
    .i_rst_n(i_rst_n), .i_clk(i_clk),
    .i_op_mode(alu_i_op_mode), .i_func_op(alu_i_func_op), 
    .i_fp_mode(alu_i_fp_mode), .i_stall(alu_i_stall),
    .i_a(alu_i_a), .i_b(alu_i_b),
    .o_result(alu_o_result),
    .o_stall(alu_o_stall)
);

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        alu_funct3 <= 0;
        alu_mem_to_reg <= 0;
        alu_reg_write <= 0;
        alu_mem_read <= 0;
        alu_mem_write <= 0;
    end else begin
        alu_funct3 <= rf_funct3;
        alu_mem_to_reg <= rf_mem_to_reg;
        alu_reg_write <= rf_reg_write;
        alu_mem_read <= rf_mem_read;
        alu_mem_write <= rf_mem_write;
    end
end

// -------------------------------------------------------------------
// data memory stage
// -------------------------------------------------------------------
// TODO
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        dmm_mem_to_reg <= 0;
        dmm_reg_write <= 0;
    end else begin
        dmm_mem_to_reg <= alu_mem_to_reg;
        dmm_reg_write <= alu_reg_write;
    end
end

// -------------------------------------------------------------------
// write back stage
// -------------------------------------------------------------------
// TODO

endmodule
