// -----------------------------------------------------------------------------
// RISC-V CPU Core
// -----------------------------------------------------------------------------

module cpu (
    //input  i_rst_n,
    //input  i_clk,
    //input  i_start,
    input  [3:0] KEY,
    input  CLOCK_50,
    // ecall pins
    output        o_ecall_ready,
    output [31:0] o_ecall_data,
    // memory I/O pins
    output DRAM_CLK,
    output [12:0] DRAM_ADDR,
    output [ 1:0] DRAM_BA,
    output DRAM_CAS_N,
    output DRAM_CKE,
    output DRAM_CS_N,
    //inout  [31:0] DRAM_DQ,
    input  [31:0] DRAM_DQ,
    output [ 3:0] DRAM_DQM,
    output DRAM_RAS_N,
    output DRAM_WE_N,
    output SRAM_WE_N,
    output SRAM_CE_N,
    output SRAM_OE_N,
    output SRAM_LB_N,
    output SRAM_UB_N,
    inout  [15:0] SRAM_DQ,
    output [19:0] SRAM_ADDR,
    // devices
    input  [17:0] SW,
    output [17:0] LEDR,
    output [ 8:0] LEDG,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5,
    output [6:0] HEX6,
    output [6:0] HEX7
);

localparam IDLE = 0;
localparam EXEC = 1;
localparam DONE = 2;

// wires & registers -------------------------------------------------
wire i_clk;
wire i_rst_n;
wire i_start;

// CPU top control
reg [1:0] state, next_state;
reg  nop;
wire next_nop;
wire stall_all, has_branch, has_jump;
wire fw_alu_rs1, fw_alu_rs2;
wire fw_dmm_rs1, fw_dmm_rs2;
reg  ecall_ready, next_ecall_ready;
reg  [31:0] ecall_data, next_ecall_data;
assign LEDR[15:0] = ecall_data[15:0] ;
assign LEDG[1:0] = {state,ecall_ready};
// program counter
reg  [31:0] pc, next_pc;

// instruction decoding stage
wire [31:0] im_sdram_address;
wire [ 3:0] im_sdram_byteenable_n;
wire im_sdram_chipselect;
wire im_sdram_read_n, im_sdram_write_n;
wire [31:0] im_sdram_writedata, im_sdram_readdata;
wire [31:0] im_o_read_data;
wire im_sdram_readdatavalid;
wire im_sdram_waitrequest;

wire [31:0] id_i_inst_data;
wire [ 4:0] id_o_rd, id_o_rs1, id_o_rs2;
reg  [ 4:0] id_rd, id_rs1, id_rs2;
reg  [ 4:0] next_id_rd, next_id_rs1, next_id_rs2;
wire [31:0] id_o_imm;
reg  [31:0] id_imm, next_id_imm;
wire [31:0] id_o_jump_imm;
reg  [31:0] id_jump_imm, next_id_jump_imm;
wire [ 2:0] id_o_funct3;
reg  [ 2:0] id_funct3, next_id_funct3;
wire id_o_ecall;
reg  id_ecall, next_id_ecall;
wire id_o_alusrc, id_o_mem_to_reg, id_o_reg_write;
reg  id_alusrc, id_mem_to_reg, id_reg_write;
reg  next_id_alusrc, next_id_mem_to_reg, next_id_reg_write;
wire id_o_mem_read, id_o_mem_write, id_o_branch;
reg  id_mem_read, id_mem_write, id_branch;
reg  next_id_mem_read, next_id_mem_write, next_id_branch;
wire [2:0] id_o_op_mode, id_o_func_op;
reg  [2:0] id_op_mode, id_func_op, next_id_op_mode, next_id_func_op;
wire id_o_fp_mode;
reg  id_fp_mode, next_id_fp_mode;

// register file stage
wire rf_i_reg_write, rf_i_stall;
wire [ 4:0] rf_i_write_rd;
wire [31:0] rf_i_write_data;
wire [ 4:0] rf_i_read_rs1;
wire [ 4:0] rf_i_read_rs2;
wire [31:0] rf_o_rs1_data;
wire [31:0] rf_o_rs2_data;

reg  [ 4:0] rf_rd, rf_rs1, rf_rs2;
reg  [ 4:0] next_rf_rd, next_rf_rs1, next_rf_rs2;
reg  [31:0] rf_imm, rf_jump_imm;
reg  [31:0] next_rf_imm, next_rf_jump_imm;
reg  [ 2:0] rf_funct3, next_rf_funct3;
reg  rf_ecall, next_rf_ecall;
reg  rf_alusrc, rf_mem_to_reg, rf_reg_write;
reg  next_rf_alusrc, next_rf_mem_to_reg, next_rf_reg_write;
reg  rf_mem_read, rf_mem_write, rf_branch;
reg  next_rf_mem_read, next_rf_mem_write, next_rf_branch;
reg  [2:0] rf_op_mode, rf_func_op;
reg  [2:0] next_rf_op_mode, next_rf_func_op;
reg  rf_fp_mode, next_rf_fp_mode;

// ALU stage
wire [2:0] alu_i_op_mode;
wire [2:0] alu_i_func_op;
wire alu_i_fp_mode;
wire alu_i_stall, alu_o_stall;
reg  [31:0] alu_i_a, alu_i_b;
wire [31:0] alu_o_result;

wire branch_success;
wire alu_jal_mode, alu_jalr_mode;
wire [31:0] alu_branch_pc, alu_jal_pc, alu_jalr_pc;

reg  [ 4:0] alu_rd, alu_rs1, alu_rs2;
reg  [31:0] alu_rs1_data, alu_rs2_data;
reg  [31:0] alu_imm, alu_jump_imm;
reg  [ 2:0] alu_funct3;
reg  alu_mem_to_reg, alu_reg_write;
reg  alu_mem_read, alu_mem_write;
reg  alu_branch;
reg  [2:0] alu_op_mode;
reg  [ 4:0] next_alu_rd, next_alu_rs1, next_alu_rs2;
reg  [31:0] next_alu_rs1_data, next_alu_rs2_data;
reg  [31:0] next_alu_imm, next_alu_jump_imm;
reg  [ 2:0] next_alu_funct3;
reg  next_alu_mem_to_reg, next_alu_reg_write;
reg  next_alu_mem_read, next_alu_mem_write;
reg  next_alu_branch;
reg  [2:0] next_alu_op_mode;

// data memory stage
wire dmm_mem_read, dmm_mem_write;
wire [31:0] dmm_address, dmm_write_data, dmm_read_data;
wire [ 2:0] dmm_funct3;
wire dmm_out_stall;

reg  [ 4:0] dmm_rd;
reg  [31:0] dmm_alu_out;
reg  dmm_mem_to_reg, dmm_reg_write;

// write back stage
wire [ 4:0] wb_rd;
wire [31:0] wb_alu_out;
wire wb_mem_to_reg, wb_reg_write;
wire [31:0] wb_reg_write_data;

// -------------------------------------------------------------------
// signal / board interface
// -------------------------------------------------------------------
assign i_clk = CLOCK_50;
assign i_rst_n = ~KEY[0];
assign i_start = KEY[3];

SevenHexDecoder SevenHex0 (
    .i_rs(ecall_data),
    .o_seven_0(HEX0),
    .o_seven_1(HEX1),
    .o_seven_2(HEX2),
    .o_seven_3(HEX3),
    .o_seven_4(HEX4),
    .o_seven_5(HEX5),
    .o_seven_6(HEX6),
    .o_seven_7(HEX7)
);

// -------------------------------------------------------------------
// CPU top control
// -------------------------------------------------------------------
// FSM
always @(*) begin
    case (state)
        IDLE: begin
            if (i_start) next_state = EXEC;
            else         next_state = IDLE;
        end
        EXEC: begin
            if (id_o_ecall) next_state = DONE;
            else            next_state = EXEC;
        end
        DONE: next_state = DONE; // remains DONE until reset
        default: next_state = IDLE;
    endcase
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) state <= IDLE;
    else          state <= next_state;
end

// CPU control
assign next_nop = (has_branch | has_jump);
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) nop <= 0;
    else          nop <= next_nop;
end

assign stall_all = (alu_o_stall | dmm_out_stall);
assign has_branch = (id_o_branch | id_branch | rf_branch);
assign has_jump = (id_branch & (id_op_mode == 4)) |
                  (rf_branch & (rf_op_mode == 4));
assign fw_alu_rs1 = alu_reg_write & (alu_rd == rf_rs1);
assign fw_alu_rs2 = alu_reg_write & (alu_rd == rf_rs2);
assign fw_dmm_rs1 = dmm_reg_write & (dmm_rd == rf_rs1);
assign fw_dmm_rs2 = dmm_reg_write & (dmm_rd == rf_rs2);

// -------------------------------------------------------------------
// program counter stage
// -------------------------------------------------------------------
always @(*) begin
    case (state) 
        IDLE: next_pc = 0;
        EXEC: begin
            if (stall_all | id_o_ecall) next_pc = pc;
            else begin
                if (branch_success)     next_pc = alu_branch_pc;
                else if (alu_jal_mode)  next_pc = alu_jal_pc;
                else if (alu_jalr_mode) next_pc = alu_jalr_pc;
                else if (nop)           next_pc = pc;
                else                    next_pc = pc + 1;
            end
        end
        DONE: next_pc = pc;
        default: next_pc = 0;
    endcase
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
assign im_sdram_address = pc;
assign im_sdram_byteenable_n = 4'd0;
assign im_sdram_chipselect = 0;
assign im_sdram_read_n = 0;
assign im_sdram_write_n = 1;
assign im_writedata = 32'd0;

inst_mem inst_mem0 (
    .i_read_addr(im_sdram_address),
    .o_read_data(im_o_read_data)
);
/*
sdram sdram0(
    .clocks_ref_clk_clk(i_clk),
    .clocks_ref_reset_reset(~i_rst_n),
    .sdram_s1_address(im_sdram_address),
    .sdram_s1_byteenable_n(im_sdram_byteenable_n),
    .sdram_s1_chipselect(im_sdram_chipselect),
    .sdram_s1_writedata(im_sdram_writedata),
    .sdram_s1_read_n(im_sdram_read_n),
    .sdram_s1_write_n(im_sdram_write_n),
    .sdram_s1_readdata(im_sdram_readdata),
    .sdram_s1_readdatavalid(im_sdram_readdatavalid),
    .sdram_s1_waitrequest(im_sdram_waitrequest),
    .clocks_sdram_clk_clk(DRAM_CLK),
    .sdram_wire_addr(DRAM_ADDR),
    .sdram_wire_ba(DRAM_BA),
    .sdram_wire_cas_n(DRAM_CAS_N),
    .sdram_wire_cke(DRAM_CKE),
    .sdram_wire_cs_n(DRAM_CS_N),
    .sdram_wire_dq(DRAM_DQ),
    .sdram_wire_dqm(DRAM_DQM),
    .sdram_wire_ras_n(DRAM_RAS_N),
    .sdram_wire_we_n(DRAM_WE_N)
);
*/
assign DRAM_ADDR = pc[12:0];
//assign id_i_inst_data = im_sdram_readdata;
//assign id_i_inst_data = DRAM_DQ;
assign id_i_inst_data = (nop) ? 0 : im_o_read_data;

inst_dec inst_dec0 (
    .i_inst_data(id_i_inst_data),
    .o_rd(id_o_rd), .o_rs1(id_o_rs1), .o_rs2(id_o_rs2),
    .o_imm(id_o_imm), .o_jump_imm(id_o_jump_imm),
    .o_funct3(id_o_funct3),
    .o_ecall(id_o_ecall),
    .o_alusrc(id_o_alusrc), 
    .o_mem_to_reg(id_o_mem_to_reg), 
    .o_reg_write(id_o_reg_write),
    .o_mem_read(id_o_mem_read), 
    .o_mem_write(id_o_mem_write),
    .o_branch(id_o_branch),
    .o_op_mode(id_o_op_mode), .o_func_op(id_o_func_op), 
    .o_fp_mode(id_o_fp_mode)
);

always @(*) begin
    /*if (nop) begin
        next_id_rd = 0; 
        next_id_rs1 = 0;
        next_id_rs2 = 0;
        next_id_imm = 0;
        next_id_jump_imm = 0;
        next_id_funct3 = 0;
        next_id_ecall = 0;
        next_id_alusrc = 0;
        next_id_mem_to_reg = 0;
        next_id_reg_write = 0;
        next_id_mem_read = 0;
        next_id_mem_write = 0;
        next_id_branch = 0;
        next_id_op_mode = 0;
        next_id_func_op = 0;
        next_id_fp_mode = 0;
    end else */if (stall_all) begin
        next_id_rd = id_rd; 
        next_id_rs1 = id_rs1;
        next_id_rs2 = id_rs2;
        next_id_imm = id_imm;
        next_id_jump_imm = id_jump_imm;
        next_id_funct3 = id_funct3;
        next_id_ecall = id_ecall;
        next_id_alusrc = id_alusrc;
        next_id_mem_to_reg = id_mem_to_reg;
        next_id_reg_write = id_reg_write;
        next_id_mem_read = id_mem_read;
        next_id_mem_write = id_mem_write;
        next_id_branch = id_branch;
        next_id_op_mode = id_op_mode;
        next_id_func_op = id_func_op;
        next_id_fp_mode = id_fp_mode;
    end else begin
        next_id_rd = id_o_rd; 
        next_id_rs1 = id_o_rs1;
        next_id_rs2 = id_o_rs2;
        next_id_imm = id_o_imm;
        next_id_jump_imm = id_o_jump_imm;
        next_id_funct3 = id_o_funct3;
        next_id_ecall = id_o_ecall;
        next_id_alusrc = id_o_alusrc;
        next_id_mem_to_reg = id_o_mem_to_reg;
        next_id_reg_write = id_o_reg_write;
        next_id_mem_read = id_o_mem_read;
        next_id_mem_write = id_o_mem_write;
        next_id_branch = id_o_branch;
        next_id_op_mode = id_o_op_mode;
        next_id_func_op = id_o_func_op;
        next_id_fp_mode = id_o_fp_mode;
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        id_rd <= 0;
        id_rs1 <= 0;
        id_rs2 <= 0;
        id_imm <= 0;
        id_jump_imm <= 0;
        id_funct3 <= 0;
        id_ecall <= 0;
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
        id_rd <= next_id_rd; 
        id_rs1 <= next_id_rs1;
        id_rs2 <= next_id_rs2;
        id_imm <= next_id_imm;
        id_jump_imm <= next_id_jump_imm;
        id_funct3 <= next_id_funct3;
        id_ecall <= next_id_ecall;
        id_alusrc <= next_id_alusrc;
        id_mem_to_reg <= next_id_mem_to_reg;
        id_reg_write <= next_id_reg_write;
        id_mem_read <= next_id_mem_read;
        id_mem_write <= next_id_mem_write;
        id_branch <= next_id_branch;
        id_op_mode <= next_id_op_mode;
        id_func_op <= next_id_func_op;
        id_fp_mode <= next_id_fp_mode;
    end
end

// -------------------------------------------------------------------
// register file stage 
// -------------------------------------------------------------------
assign rf_i_reg_write = wb_reg_write;
assign rf_i_stall = stall_all;
assign rf_i_write_rd = wb_rd;
assign rf_i_write_data = wb_reg_write_data;
assign rf_i_read_rs1 = id_rs1;
assign rf_i_read_rs2 = id_rs2;

reg_file reg_file0 (
    .i_rst_n(i_rst_n), .i_clk(i_clk), .i_stall(rf_i_stall),
    .i_reg_write(rf_i_reg_write),
    .i_write_rd(rf_i_write_rd), .i_write_data(rf_i_write_data),
    .i_read_rs1(rf_i_read_rs1), .i_read_rs2(rf_i_read_rs2),
    .o_rs1_data(rf_o_rs1_data), .o_rs2_data(rf_o_rs2_data)
);

always @(*) begin
    if (stall_all) begin
        next_rf_rd = rf_rd;
        next_rf_rs1 = rf_rs1;
        next_rf_rs2 = rf_rs2;
        next_rf_imm = rf_imm;
        next_rf_jump_imm = rf_jump_imm;
        next_rf_funct3 = rf_funct3;
        next_rf_ecall = rf_ecall;
        next_rf_alusrc = rf_alusrc;
        next_rf_mem_to_reg = rf_mem_to_reg;
        next_rf_reg_write = rf_reg_write;
        next_rf_mem_read = rf_mem_read;
        next_rf_mem_write = rf_mem_write;
        next_rf_branch = rf_branch;
        next_rf_op_mode = rf_op_mode;
        next_rf_func_op = rf_func_op;
        next_rf_fp_mode = rf_fp_mode;
    end else begin
        next_rf_rd = id_rd; 
        next_rf_rs1 = id_rs1;
        next_rf_rs2 = id_rs2;
        next_rf_imm = id_imm;
        next_rf_jump_imm = id_jump_imm;
        next_rf_funct3 = id_funct3;
        next_rf_ecall = id_ecall;
        next_rf_alusrc = id_alusrc;
        next_rf_mem_to_reg = id_mem_to_reg;
        next_rf_reg_write = id_reg_write;
        next_rf_mem_read = id_mem_read;
        next_rf_mem_write = id_mem_write;
        next_rf_branch = id_branch;
        next_rf_op_mode = id_op_mode;
        next_rf_func_op = id_func_op;
        next_rf_fp_mode = id_fp_mode;
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        rf_rd <= 0;
        rf_rs1 <= 0;
        rf_rs2 <= 0;
        rf_imm <= 0;
        rf_jump_imm <= 0;
        rf_funct3 <= 0;
        rf_ecall <= 0;
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
        rf_rd <= next_rf_rd; 
        rf_rs1 <= next_rf_rs1;
        rf_rs2 <= next_rf_rs2;
        rf_imm <= next_rf_imm;
        rf_jump_imm <= next_rf_jump_imm;
        rf_funct3 <= next_rf_funct3;
        rf_ecall <= next_rf_ecall;
        rf_alusrc <= next_rf_alusrc;
        rf_mem_to_reg <= next_rf_mem_to_reg;
        rf_reg_write <= next_rf_reg_write;
        rf_mem_read <= next_rf_mem_read;
        rf_mem_write <= next_rf_mem_write;
        rf_branch <= next_rf_branch;
        rf_op_mode <= next_rf_op_mode;
        rf_func_op <= next_rf_func_op;
        rf_fp_mode <= next_rf_fp_mode;
    end
end

// -------------------------------------------------------------------
// ALU stage 
// -------------------------------------------------------------------
// ecall signals
always @(*) begin
    if (rf_ecall) begin
        next_ecall_ready = 1;
        next_ecall_data = alu_i_a;
    end else begin
        next_ecall_ready = 0;
        next_ecall_data = 0;
    end
end
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        ecall_ready <= 0;
        ecall_data <= 0;
    end else begin
        ecall_ready <= next_ecall_ready;
        ecall_data <= next_ecall_data;
    end
end
assign o_ecall_ready = ecall_ready;
assign o_ecall_data = ecall_data;

// ALU input
assign alu_i_op_mode = rf_op_mode;
assign alu_i_func_op = rf_func_op;
assign alu_i_fp_mode = rf_fp_mode;
assign alu_i_stall = stall_all;

always @(*) begin
    if (fw_alu_rs1)      alu_i_a = alu_o_result;
    else if (fw_dmm_rs1) alu_i_a = dmm_alu_out;
    else                 alu_i_a = rf_o_rs1_data; // no forwarding

    if (rf_alusrc)       alu_i_b = rf_imm;
    else if (fw_alu_rs2) alu_i_b = alu_o_result;
    else if (fw_dmm_rs2) alu_i_b = dmm_alu_out;
    else                 alu_i_b = rf_o_rs2_data; // no forwarding
end

alu alu0 (
    .i_rst_n(i_rst_n), .i_clk(i_clk),
    .i_op_mode(alu_i_op_mode), .i_func_op(alu_i_func_op), 
    .i_fp_mode(alu_i_fp_mode), .i_stall(alu_i_stall),
    .i_a(alu_i_a), .i_b(alu_i_b),
    .o_result(alu_o_result),
    .o_stall(alu_o_stall)
);

// branch / jump
assign branch_success = (alu_branch & (alu_op_mode == 3) & alu_o_result[0]);
assign alu_jal_mode = (alu_branch & (alu_op_mode == 4) & !alu_jump_imm[31]);
assign alu_jalr_mode = (alu_branch & (alu_op_mode == 4) & alu_jump_imm[31]);
assign alu_branch_pc = $signed(pc) + $signed(alu_imm[31:2]) - 1;
assign alu_jal_pc = $signed(pc) + $signed(alu_jump_imm[20:2]);
assign alu_jalr_pc = $signed(alu_rs1_data) + $signed(alu_jump_imm[11:0]);

// irrelevant pipeline signals
always @(*) begin
    if (stall_all) begin
        next_alu_rd = alu_rd; 
        next_alu_rs1 = alu_rs1;
        next_alu_rs2 = alu_rs2;
        next_alu_rs1_data = alu_rs1_data;
        next_alu_rs2_data = alu_rs2_data;
        next_alu_imm = alu_imm;
        next_alu_jump_imm = alu_jump_imm;
        next_alu_funct3 = alu_funct3;
        next_alu_mem_to_reg = alu_mem_to_reg;
        next_alu_reg_write = alu_reg_write;
        next_alu_mem_read = alu_mem_read;
        next_alu_mem_write = alu_mem_write;
        next_alu_branch = alu_branch;
        next_alu_op_mode = alu_op_mode;
    end else begin
        next_alu_rd = rf_rd; 
        next_alu_rs1 = rf_rs1;
        next_alu_rs2 = rf_rs2;
        next_alu_rs1_data = rf_o_rs1_data;
        next_alu_rs2_data = rf_o_rs2_data;
        next_alu_imm = rf_imm;
        next_alu_jump_imm = rf_jump_imm;
        next_alu_funct3 = rf_funct3;
        next_alu_mem_to_reg = rf_mem_to_reg;
        next_alu_reg_write = rf_reg_write;
        next_alu_mem_read = rf_mem_read;
        next_alu_mem_write = rf_mem_write;
        next_alu_branch = rf_branch;
        next_alu_op_mode = rf_op_mode;
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        alu_rd <= 0; 
        alu_rs1 <= 0;
        alu_rs2 <= 0;
        alu_rs1_data <= 0;
        alu_rs2_data <= 0;
        alu_imm <= 0;
        alu_jump_imm <= 0;
        alu_funct3 <= 0;
        alu_mem_to_reg <= 0;
        alu_reg_write <= 0;
        alu_mem_read <= 0;
        alu_mem_write <= 0;
        alu_branch <= 0;
        alu_op_mode <= 0;
    end else begin
        alu_rd <= next_alu_rd; 
        alu_rs1 <= next_alu_rs1;
        alu_rs2 <= next_alu_rs2;
        alu_rs1_data <= next_alu_rs1_data;
        alu_rs2_data <= next_alu_rs2_data;
        alu_imm <= next_alu_imm;
        alu_jump_imm <= next_alu_jump_imm;
        alu_funct3 <= next_alu_funct3;
        alu_mem_to_reg <= next_alu_mem_to_reg;
        alu_reg_write <= next_alu_reg_write;
        alu_mem_read <= next_alu_mem_read;
        alu_mem_write <= next_alu_mem_write;
        alu_branch <= next_alu_branch;
        alu_op_mode <= next_alu_op_mode;
    end
end

// -------------------------------------------------------------------
// data memory stage
// -------------------------------------------------------------------
assign dmm_mem_read = alu_mem_read;
assign dmm_mem_write = alu_mem_write;
assign dmm_address = alu_o_result;
assign dmm_write_data = alu_rs2_data;
assign dmm_funct3 = alu_funct3;

stage4_memory dmm0 (
    .rst_n(i_rst_n), .clk(i_clk),
    .mem_read(dmm_mem_read), .mem_write(dmm_mem_write),
    .address(dmm_address), .write_data(dmm_write_data),
    .funct3(dmm_funct3), .bubble(dmm_out_stall),
    .read_data(dmm_read_data),
    .o_SRAM_WE_N(SRAM_WE_N),
    .o_SRAM_CE_N(SRAM_CE_N),
    .o_SRAM_OE_N(SRAM_OE_N),
    .o_SRAM_LB_N(SRAM_LB_N),
    .o_SRAM_UB_N(SRAM_UB_N),
    .o_SRAM_DQ(SRAM_DQ),
    .o_SRAM_ADDR(SRAM_ADDR)
);

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        dmm_rd <= 0;
        dmm_alu_out <= 0;
        dmm_mem_to_reg <= 0;
        dmm_reg_write <= 0;
    end else begin
        dmm_rd <= alu_rd;
        dmm_alu_out <= alu_o_result;
        dmm_mem_to_reg <= alu_mem_to_reg;
        dmm_reg_write <= alu_reg_write;
    end
end

// -------------------------------------------------------------------
// write back stage
// -------------------------------------------------------------------
assign wb_rd = dmm_rd;
assign wb_alu_out = dmm_alu_out;
assign wb_mem_out = dmm_read_data;
assign wb_mem_to_reg = dmm_mem_to_reg;
assign wb_reg_write = dmm_reg_write;
assign wb_reg_write_data = (wb_mem_to_reg) ? wb_mem_out : wb_alu_out;

endmodule
