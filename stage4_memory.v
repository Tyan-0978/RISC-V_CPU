module stage4_memory (
    input clk,
	input rst_n,
    input mem_read,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    input [2:0] funct3,
    output bubble,
    output [31:0] read_data,
    output o_SRAM_WE_N,
    output o_SRAM_CE_N,
    output o_SRAM_OE_N,
    output o_SRAM_LB_N,
    output o_SRAM_UB_N,
    inout [15:0] o_SRAM_DQ, 
    output [19:0] o_SRAM_ADDR
);

wire [19:0] addr;
wire [15:0] sram_read;
reg SRAM_LB, SRAM_UB;
reg bubble_w, bubble_r;
reg [31:0] read_register_w, read_register_r;
reg [15:0] sram_write;

assign bubble = bubble_r;
assign read_data = read_register_r;
assign o_SRAM_WE_N = (mem_write) ? 1'b0 : 1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = SRAM_LB;
assign o_SRAM_UB_N = SRAM_UB;
assign o_SRAM_DQ = (mem_write) ? sram_write : 16'dz; 
assign o_SRAM_ADDR = (bubble_r) ? addr+1 : addr;
assign addr = {address[18:0],1'b0}; 
assign sram_read = (!mem_write) ? o_SRAM_DQ : 16'd0;

always@(*) begin
	if (mem_read) begin
        case (funct3)
            // LB
            3'b000: begin 
                bubble_w = 0;
                read_register_w = sram_read[15] ? {{24{1'b1}},sram_read[15:8]} : {24'd0,sram_read[15:8]};
                SRAM_UB = 0;
                SRAM_LB = 0;
            end
				
            // LH
            3'b001: begin
                bubble_w = 0;
                read_register_w = sram_read[15] ? {{16{1'b1}},sram_read[15:0]} : {16'd0,sram_read[15:0]};
					 SRAM_UB = 0;
					 SRAM_LB = 0;
            end
            // LW
            3'b010: begin
					SRAM_UB = 0;
					SRAM_LB = 0;
					// second access to memory 
					if (bubble_r) begin
						 bubble_w = 0;
						 read_register_w = {read_register_r[31:16],sram_read[15:0]};
					end
					// first access to memory
					else begin
						 bubble_w = 1;
						 read_register_w = {sram_read[15:0],read_register_r[15:0]};
						 
					end
            end
            // LBU
            3'b100: begin
            // second access to memory 
                bubble_w = 0;
                read_register_w = {24'd0,sram_read[15:8]};
					 SRAM_UB = 0;
					 SRAM_LB = 0;
            end
            // LHU
            3'b101: begin
                bubble_w = 0;
                read_register_w = {16'd0,sram_read[15:0]};
					 SRAM_UB = 0;
					 SRAM_LB = 0;
            end
				
            default: begin
					bubble_w = 0;
					read_register_w = 32'd0;
					SRAM_LB = 0;
					SRAM_UB = 0;
				end
        endcase
    end
	else if (mem_write) begin
        case (funct3)
            // SB (need a special test for this instruction!!)
            3'b000: begin
                bubble_w = 0;
                sram_write = {write_data[7:0],8'd0};
                SRAM_UB = 0;
                SRAM_LB = 1;
            end
            // SH
            3'b001: begin
                bubble_w = 0;
                sram_write = write_data[15:0];
					 SRAM_UB = 0;
                SRAM_LB = 0;
            end
            // SW
            3'b010: begin
					 SRAM_UB = 0;
					 SRAM_LB = 0;
                // represents second access to memory
                if (bubble_r) begin
                    sram_write = write_data[15:0];
                    bubble_w = 0;
                // represents first access to memory
				end
                else begin
                    sram_write = write_data[31:16];
                    bubble_w = 1;
                end
            end
            default: begin
                bubble_w = 0;
                SRAM_LB = 0;
                SRAM_UB = 0;
            end
        endcase
    end
	else begin
        SRAM_UB = 0;
        SRAM_LB = 0;
        bubble_w = 0;
	end
end
always @ (posedge clk or negedge rst_n)begin 
    if(!rst_n) begin
        bubble_r <= 0;
        read_register_r <= 32'd0;
    end
    else begin
        bubble_r <= bubble_w;
        read_register_r <= read_register_w;
    end
end

endmodule
