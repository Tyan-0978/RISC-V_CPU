module inst_dec(

);

//-----------Instruction Set-------------//
wire [6:0] opcode;
wire [2:0] funct3;
wire [6:0] funct7;

//----------OP Code--------------------------//
parameter R_TYPE_OP = 7'b0110011;
parameter JAL_OP    = 7'b1101111;
parameter JALR_OP   = 7'b1100111;
parameter B_type_OP = 7'b1100011;
parameter LW_OP     = 7'b0000011;
parameter SW_OP     = 7'b0100011;
parameter I_TYPE_OP = 7'b0010011;
parameter AUIPC_OP  = 7'b0010111;

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
assign opcode = mem_rdata_I[ 6: 0];
assign rd     = mem_rdata_I[ 11:7];
assign funct3 = mem_rdata_I[14:12];
assign rs1    = mem_rdata_I[19:15];
assign rs2    = mem_rdata_I[24:20];
assign funct7 = mem_rdata_I[31:25];

endmodule