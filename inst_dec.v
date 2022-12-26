module inst_dec(
    input [31:0] i_inst_data,
    output reg [4:0] o_rd,
    output reg [4:0] o_rs1,
    output reg [4:0] o_rs2,
    output reg [31:0] o_imm,
    output reg [31:0] o_jump_imm,
    output reg o_ecall,
    output reg [2:0] o_funct3,
    output reg o_alusrc,
    output reg o_mem_to_reg,
    output reg o_reg_write,
    output reg o_mem_read,
    output reg o_mem_write,
    output reg o_branch,
    output reg [2:0] o_op_mode,
    output reg [2:0] o_func_op,
    output reg o_fp_mode
);

//----------OP Code--------------------------//
// RV32I
parameter LUI_OP    = 7'b0110111;
parameter AUIPC_OP  = 7'b0010111;
parameter JAL_OP    = 7'b1101111;
parameter JALR_OP   = 7'b1100111;
parameter B_type_OP = 7'b1100011;   // BEQ BNE BLT BGE BLTU BGEU
parameter LOAD_OP   = 7'b0000011;   // LB LH LW LBU LHU
parameter STORE_OP  = 7'b0100011;   // SB SH SW
parameter I_TYPE_OP = 7'b0010011;   // ADDI SLTI SLTIU XORI ORI ANDI SLLI SRLI SRAI
parameter R_TYPE_OP = 7'b0110011;   // ADD SUB SLL SLT SLTU XOR SRL SRA OR AND
// RV32M
                                    // MUL MULH MULHSU MULHU DIV DIVU REM REMU

// parameter FENCE_OP  = 7'b0001111;   // FENCE FENCE.I
parameter E_OP      = 7'b1110011;   // ECALL EBREAK
                                    // CSRRW CSRRS CSRRC CSRRWI CSRRSI CSRRCI

// RV32A XXX

// RV32F
/*
parameter FLW_OP    = 7'b0000111;
parameter FSW_OP    = 7'b0100111;
parameter FMADD.S_OP    = 7'b1000011;
parameter FMSUB.S_OP    = 7'b1000111;
parameter FNMSUB.S_OP   = 7'b1001011;
parameter FNMADD.S_OP   = 7'b1001111;
parameter F_OP      = 7'b1010011;    // F~
*/
// RV32D

//-----------Instruction Set-------------//
wire [6:0] opcode;
wire [4:0] rd, rs1, rs2;
wire [2:0] funct3;
wire [6:0] funct7;

//-----------Instruction Decode----------------//
assign opcode = i_inst_data[ 6: 0];
assign rd     = i_inst_data[ 11:7];
assign funct3 = i_inst_data[14:12];
assign rs1    = i_inst_data[19:15];
assign rs2    = i_inst_data[24:20];
assign funct7 = i_inst_data[31:25];


//----------decoder---------//
always@(*) begin
    o_funct3 = funct3;

    if (opcode == JAL_OP)
        o_jump_imm = {11'd0, i_inst_data[31], i_inst_data[19:12], i_inst_data[20], i_inst_data[30:21], 1'b0};
    else if (opcode == JALR_OP && funct3 == 3'b000)
        o_jump_imm = {20'd1, i_inst_data[31:20]};
    else 
        o_jump_imm = 0;

    if (opcode == E_OP)
        o_ecall = 1;
    else 
        o_ecall = 0;
    
    case (opcode)
        // RV32I
        LUI_OP: begin // notice
            o_op_mode = 0;
            o_func_op = 3'b000;
            o_fp_mode = 0;
            o_rd = rd;
            o_rs1 = 5'b00000;
            o_rs2 = 5'b00000;
            o_imm = {i_inst_data[31:12], 12'd0};
            o_alusrc = 1;
            o_mem_to_reg = 0;
            o_reg_write = 1;
            o_mem_read = 0;
            o_mem_write = 0;
            o_branch = 0;
        end
        /*
        AUIPC_OP: begin // TB Checked
            o_op_mode = 0;
            o_func_op = 3'b000;
            o_fp_mode = 0;
            o_rd = rd;
            o_rs1 = 5'b00000;
            o_rs2 = 5'b00000;
            o_imm = {i_inst_data[31:12], 12'd0};
            o_alusrc = 1;
            o_mem_to_reg = 0;
            o_reg_write = 1;
            o_mem_read = 0;
            o_mem_write = 0;
            o_branch = 1;
        end
        */
        JAL_OP: begin //TB Checked
            o_op_mode = 4;
            o_func_op = 3'b000;
            o_fp_mode = 0;
            o_rd = rd;
            o_rs1 = rs1;
            o_rs2 = 5'b00000;
            o_imm = 1;
            o_alusrc = 1;
            o_mem_to_reg = 0;
            o_reg_write = 1;
            o_mem_read = 0;
            o_mem_write = 0;
            o_branch = 1;
        end 
        JALR_OP: begin //TB checked
            if (funct3 == 3'b000) begin
                o_op_mode = 4;
                o_func_op = 3'b000;
                o_fp_mode = 0;
                o_rd = rd;
                o_rs1 = rs1;
                o_rs2 = 0;
                o_imm = 1;
            end
            else begin // something wrong
                o_op_mode = 0;
                o_func_op = 3'b000;
                o_fp_mode = 0;
                o_rd = 0;
                o_rs1 = 0;
                o_rs2 = 0;
                o_imm = 0;
            end
            o_alusrc = 1;
            o_mem_to_reg = 0;
            o_reg_write = 1;
            o_mem_read = 0;
            o_mem_write = 0;
            o_branch = 1;
        end
        B_type_OP: begin
            o_op_mode = 3;
            case (funct3) 
                3'b000: //BEQ
                    o_func_op = 3'b101;
                3'b001: //BNE
                    o_func_op = 3'b100;
                3'b100: //BLT
                    o_func_op = 3'b000;
                3'b101: //BGE
                    o_func_op = 3'b011;
                3'b110: //BLTU (currently do the same thing as BLT)
                    o_func_op = 3'b000;
                3'b111: //BGEU (currently do the same thing as BGE)
                    o_func_op = 3'b011;
                default:
                    o_func_op = 0;
            endcase
            o_fp_mode = 0;
            o_rd = 5'b00000;
            o_rs1 = rs1;
            o_rs2 = rs2;
            o_imm = {{20{i_inst_data[31]}}, i_inst_data[31], i_inst_data[7], i_inst_data[30:25], i_inst_data[11:8], 1'b0};
            o_alusrc = 0;
            o_mem_to_reg = 0;
            o_reg_write = 0;
            o_mem_read = 0;
            o_mem_write = 0;
            o_branch = 1;
        end
        LOAD_OP: begin
            o_op_mode = 4;
            o_func_op = 3'b000;
            o_fp_mode = 0;
            o_rd = rd;
            o_rs1 = rs1;
            o_rs2 = 5'b00000;
            o_imm = {{20{i_inst_data[31]}}, i_inst_data[31:20]};
            o_alusrc = 1;
            o_mem_to_reg = 1;
            o_reg_write = 1;
            o_mem_read = 1;
            o_mem_write = 0;
            o_branch = 0;
        end
        STORE_OP: begin
            o_op_mode = 4;
            o_func_op = 3'b000;
            o_fp_mode = 0;
            o_rd = 5'b00000;
            o_rs1 = rs1;
            o_rs2 = rs2;
            o_imm = {{20{i_inst_data[31]}}, i_inst_data[31:25], i_inst_data[11:7]};
            o_alusrc = 1;
            o_mem_to_reg = 0;
            o_reg_write = 0;
            o_mem_read = 0;
            o_mem_write = 1;
            o_branch = 0;
        end
        I_TYPE_OP: begin
            case (funct3) 
                3'b000: begin //ADDI
                    o_op_mode = 4;
                    o_func_op = 3'b000;
		            o_imm = {{20{i_inst_data[31]}}, i_inst_data[31:20]};
                end
                3'b010: begin //SLTI set less then immediate
                    o_op_mode = 3;
                    o_func_op = 3'b000;
                    o_imm = {{20{i_inst_data[31]}}, i_inst_data[31:20]};
                end
                3'b011: begin //SLTIU (currently do the same thing as SLTI) 
                    o_op_mode = 3;
                    o_func_op = 3'b000;
                    o_imm = {{20{i_inst_data[31]}}, i_inst_data[31:20]};
                end
                3'b100: begin //XORI
                    o_op_mode = 1;
                    o_func_op = 3'b010;
                    o_imm = {{20{i_inst_data[31]}}, i_inst_data[31:20]};
                end
                3'b110: begin //ORI
                    o_op_mode = 1;
                    o_func_op = 3'b001;
                    o_imm = {{20{i_inst_data[31]}}, i_inst_data[31:20]};
                end
                3'b111: begin //ANDI
                    o_op_mode = 1;
                    o_func_op = 3'b000;
                    o_imm = {{20{i_inst_data[31]}}, i_inst_data[31:20]};
                end
                3'b001: begin //SLLI
                    o_op_mode = 2;
                    o_func_op = 3'b000;
                    o_imm = {{27'd0}, i_inst_data[24:20]};
                end
                3'b101: begin
                    if (funct7 == 7'b0000000) begin //SRLI
                        o_op_mode = 2;
                        o_func_op = 3'b010;
                    end
                    else if (funct7 == 7'b0100000) begin //SRAI
                        o_op_mode = 2;
                        o_func_op = 3'b011;
                    end
                    else begin // something wrong
                        o_op_mode = 0;
                        o_func_op = 3'b000;
                    end
                    o_imm = {{27'd0}, i_inst_data[24:20]};
                end
                default: begin
                    o_op_mode = 0;
                    o_func_op = 0;
                    o_imm = 32'd0;
                end
            endcase 
            o_fp_mode = 0;
            o_rd = rd;
            o_rs1 = rs1;
            o_rs2 = 5'b00000;
            o_alusrc = 1;
            o_mem_to_reg = 0;
            o_reg_write = 1;
            o_mem_read = 1;
            o_mem_write = 0;
            o_branch = 0;
        end
        R_TYPE_OP: begin
            case(funct3) 
                3'b000: begin
                    if (funct7 == 7'b0000000) begin // ADD
                        o_op_mode = 4;
                        o_func_op = 3'b000;
                    end
                    else if (funct7 == 7'b0100000) begin // SUB
                        o_op_mode = 4;
                        o_func_op = 3'b001;
                    end
                    else if (funct7 == 7'b0000001) begin // MUL
                        o_op_mode = 5;
                        o_func_op = 3'b000;
                    end
                    else begin //something wrong 
                        o_op_mode = 0;
                        o_func_op = 3'b111;
                    end
                end
                3'b001: begin 
                    if (funct7 == 7'b0000000) begin // SLL
                        o_op_mode = 2;
                        o_func_op = 3'b000;
                    end
                    else begin //something wrong (or MULH)
                        o_op_mode = 0;
                        o_func_op = 3'b000;
                    end
                end
                3'b010: begin // SLT
                    o_op_mode = 3;
                    o_func_op = 3'b000;
                end
                3'b011: begin // SLTU (currently do the same thing as SLT)
                    o_op_mode = 3;
                    o_func_op = 3'b000;
                end
                3'b100: begin 
                    if (funct7 == 7'b0000000) begin // XOR
                        o_op_mode = 1;
                        o_func_op = 3'b010;
                    end
                    else if (funct7 == 7'b0000001) begin // DIV
                        o_op_mode = 6;
                        o_func_op = 3'b000;
                    end
                    else begin // something wrong
                        o_op_mode = 0;
                        o_func_op = 3'b000;
                    end
                end
                3'b101: begin
                    if (funct7 == 7'b0000000) begin //SRL
                        o_op_mode = 2;
                        o_func_op = 3'b010;
                    end
                    else if (funct7 == 7'b0100000) begin //SRA
                        o_op_mode = 2;
                        o_func_op = 3'b011;
                    end
                    else begin // something wrong
                        o_op_mode = 0;
                        o_func_op = 3'b000;
                    end
                end
                3'b110: begin 
                    if (funct7 == 7'b0000000) begin // OR
                        o_op_mode = 1;
                        o_func_op = 3'b001;
                    end
                    else if (funct7 == 7'b0000001) begin // REM
                        o_op_mode = 7;
                        o_func_op = 3'b000;
                    end
                    else begin // something wrong
                        o_op_mode = 0;
                        o_func_op = 3'b000;
                    end
                end
                3'b111: begin // AND
                    o_op_mode = 1;
                    o_func_op = 3'b000;
                end
                default: begin
                    o_op_mode = 0;
                    o_func_op = 3'b000;
                end
            endcase
            o_imm = 0;
            o_fp_mode = 0;
            o_rd = rd;
            o_rs1 = rs1;
            o_rs2 = rs2;
            o_alusrc = 0;
            o_mem_to_reg = 0;
            o_reg_write = 1;
            o_mem_read = 0;
            o_mem_write = 0;
            o_branch = 0;
        end
        // FENCE_OP:
        E_OP: begin
            o_op_mode = 0;
            o_func_op = 3'b000;
            o_fp_mode = 0;
            o_rd = 0;
            o_rs1 = rs1;
            o_rs2 = 0;
            o_imm = 0;
            o_alusrc = 0;
            o_mem_to_reg = 0;
            o_reg_write = 0;
            o_mem_read = 0;
            o_mem_write = 0;
            o_branch = 0;
        end

        // RV32F
        /*
        FLW_OP:

        FSW_OP:

        FMADD.S_OP:

        FMSUB.S_OP:

        FNMSUB.S_OP:

        FNMADD.S_OP:

        F_OP:

        */
        default: begin
            o_op_mode = 0;
            o_func_op = 0;
            o_fp_mode = 0;
            o_rd = 0;
            o_rs1 = 0;
            o_rs2 = 0;
            o_imm = 0;
            o_alusrc = 0;
            o_mem_to_reg = 0;
            o_reg_write = 0;
            o_mem_read = 0;
            o_mem_write = 0;
            o_branch = 0;
        end
    endcase

end
endmodule
