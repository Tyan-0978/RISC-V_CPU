module inst_dec(
    input [31:0] inst_data;
    output []
);







//----------OP Code--------------------------//
// RV32I
parameter LUI_OP    = 7'b0110111;
parameter AUIPC_OP  = 7'b0010111;
parameter JAL_OP    = 7'b1101111;
parameter JALR_OP   = 7'b1100111;
parameter B_type_OP = 7'b1100011;   // BEQ BNE BLT BGE BLTU BGEU
parameter LOAD_OP   = 7'b0000011;   // LB LH LW LBU LHU
parameter SW_OP     = 7'b0100011;   // SB SH SW
parameter I_TYPE_OP = 7'b0010011;   // ADDI SLTI SLTIU XORI ORI ANDI SLLI SRLI SRAI
parameter R_TYPE_OP = 7'b0110011;   // ADD SUB SLL SLT SLTU XOR SRL SRA OR AND
// RV32M
                                    // MUL MULH MULHSU MULHU DIV DIVU REM REMU

parameter FENCE_OP  = 7'b0001111;   // FENCE FENCE.I
parameter E_OP      = 7'b1110011;   // ECALL EBREAK
                                    // CSRRW CSRRS CSRRC CSRRWI CSRRSI CSRRCI

// RV32A
parameter 

// RV32F
parameter FLW_OP    = 7'b0000111;
parameter FSW_OP    = 7'b0100111;
parameter FMADD.S_OP    = 7'b1000011;
parameter FMSUB.S_OP    = 7'b1000111;
parameter FNMSUB.S_OP   = 7'b1001011;
parameter FNMADD.S_OP   = 7'b1001111;
parameter F_OP      = 7'b1010011;    // F~

// RV32D

//----------Funct3--------------------------//
parameter JALR_F3   = 3'b000;
parameter BEQ_F3    = 3'b000;
parameter LW_F3     = 3'b010;
parameter SW_F3     = 3'b010;
parameter ADDI_F3   = 3'b000;
parameter SLTI_F3   = 3'b010;
parameter ADD_F3    = 3'b000;
parameter SUB_F3    = 3'b000;
parameter MUL_F3    = 3'b000;
parameter XOR_F3    = 3'b100;
parameter BGE_F3    = 3'b101;   //BONUS
parameter BLT_F3    = 3'b100;   //BONUS
parameter SRLI_F3   = 3'b101;   //BONUS
parameter SLLI_F3   = 3'b001;   //BONUS

//----------Funct7--------------------------//
parameter ADD_F7 = 7'b0000000;
parameter SUB_F7 = 7'b0100000;
parameter MUL_F7 = 7'b0000001;
parameter XOR_F7 = 7'b0000000;
parameter SLLI_F7 = 7'b0000000 ; //BONUS
parameter SRAI_F7 =  7'b0100000;  //BONUS

//-----------Instruction Decode----------------//
assign opcode = inst_data[ 6: 0];
assign rd     = inst_data[ 11:7];
assign funct3 = inst_data[14:12];
assign rs1    = inst_data[19:15];
assign rs2    = inst_data[24:20];
assign funct7 = inst_data[31:25];

//-----------Instruction Set-------------//
wire [6:0] opcode;
wire [2:0] funct3;
wire [6:0] funct7;

//----------decoder---------//
always@(*) begin
    case (opcode)
        // RV32I
        LUI_OP:

        AUIPC_OP:

        JAL_OP:

        JALR_OP:

        B_type_OP:

        LOAD_OP:

        SW_OP:

        I_TYPE_OP:
        
        R_TYPE_OP:

        FENCE_OP:

        E_OP:

        // RV32F
        FLW_OP:

        FSW_OP:

        FMADD.S_OP:

        FMSUB.S_OP:

        FNMSUB.S_OP:

        FNMADD.S_OP:

        F_OP:


    endcase

end
endmodule