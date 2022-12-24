module data_memory(
    input   [19:0] addr,
	input   [31:0] write_data,
    input          mem_read,
    input   [2:0]  funct3,
    input          mem_write,
    output         bubble,
	output  [15:0] read_data,
    output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,
    output [19:0] o_SRAM_ADDR 
     

);
logic [31:0] sram_addr;
logic bubble_w, bubble_r;
logic [31:0] read_register_w, read_register_r;
logic  SRAM_UB, SRAM_LB;
assign o_SRAM_WE_N = (mem_write) ? 1'b0 : 1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = SRAM_LB
assign o_SRAM_UB_N = SRAM_UB;
assign io_SRAM_DQ = (mem_write) ? sram_write : 16'dz; 
assign o_SRAM_ADDR = sram_addr;
assign read_data = (!mem_write) ? io_SRAM_DQ : 16'd0;
always_comb begin
    if(mem_read) begin
        case (funct3)
            // LB
            3'b000: begin 
                bubble_w = 0;
                sram_addr = addr;
                read_register_w = read_data[15] ? {24{1'b1},read_data[15:8]} : {24'd0,read_data[15:8]};
            end
            // LH
            3'b001: begin
                bubble_w = 0;
                sram_addr = addr;
                read_register_w = read_data[15] ? {16{1'b1},read_data[15:0]} : {16'd0,read_data[15:0]};
            end
            // LW
            3'b010: begin
            // second access to memory 
            if (bubble_r) begin
                bubble_w = 0;
                sram_addr = addr+1;
                read_register_w[15:0] = read_data[15:0];
            end
            // first access to memory
            else begin
                bubble_w = 1;
                sram_addr = addr;
                read_register_w[31:16] = read_data[15:0];
            end
            end
            // LBU
            3'b100: begin
            // second access to memory 
                bubble_w = 0;
                sram_addr = addr;
                read_register_w = {24'd0,read_data[15:8]};
            end
            // LHU
            3'b101: begin
                bubble_w = 0;
                sram_addr = addr;
                read_register_w = {16'd0,read_data[15:0]};
            end

            default: bubble_w = 0;
        endcase
    end
    else bubble_w = 0;
    if (mem_write) begin
        case (funct3)
            // SB (need a special test for this instruction!!)
            3'b000: begin
                bubble_w = 0;
                sram_addr = addr;
                sram_write = {write_data[7:0],8'd0};
                SRAM_UB = 0;
                SRAM_LB = 1;
            end
            // SH
            3'b001: begin
                bubble_w = 0;
                sram_addr = addr;
                sram_write = write_data[15:0];
            end
            // SW
            3'b010: begin
                // represents second access to memory
                if (bubble_r) begin
                    sram_addr = addr + 1;
                    sram_write = write_data[15:0];
                    bubble_w = 0;
                // represents first access to memory
                else begin
                    sram_addr = addr;
                    sram_write = write_data[31:16];
                    bubble_w = 1;
                end
            end
            default: begin
                bubble_w = 0;
                sram_addr = addr;
                SRAM_LB = 0;
                SRAM_UB = 0;
                sram_write = 16'd0;
            end
        endcase
    end
    else bubble_w = 0; 

end
always @ (posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        bubble_r <= 0;
        read_register_r <= 32'd0;
    end
    else begin
        bubble_r <= bubble_w;
        read_register_r <= read_register_w;
    end
end
endmodule