// handle data send to/from memory 
module data_memory (
	input i_clk,
    input [31:0] i_write_data,
    input i_mem_read,
    input i_mem_write,
    input [2:0] i_funct3,
    input [15:0] i_sram_read,
    output o_bubble,
    output [31:0] o_read_register,
    output o_LB_N,
    output o_UB_N,
    output [15:0] o_sram_write,

);
assign o_bubble = bubble_r;
assign o_LB_N = SRAM_LB;
assign o_UB_N = SRAM_UB;
assign o_sram_write = sram_write;
assign o_read_register = read_register_r;

reg [15:0] sram_write;

always@(*) begin
	if (i_mem_read) begin
        case (i_funct3)
            // LB
            3'b000: begin 
                bubble_w = 0;
                read_register_w = read_data[15] ? {{24{1'b1}},read_data[15:8]} : {24'd0,read_data[15:8]};
                SRAM_UB = 0;
                SRAM_LB = 0;
            end
				
            // LH
            3'b001: begin
                bubble_w = 0;
                read_register_w = read_data[15] ? {{16{1'b1}},read_data[15:0]} : {16'd0,read_data[15:0]};
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
                read_register_w[15:0] = read_data[15:0];
            end
            // first access to memory
            else begin
                bubble_w = 1;
                read_register_w[31:16] = read_data[15:0];
					 
            end
            end
            // LBU
            3'b100: begin
            // second access to memory 
                bubble_w = 0;
                read_register_w = {24'd0,read_data[15:8]};
					 SRAM_UB = 0;
					 SRAM_LB = 0;
            end
            // LHU
            3'b101: begin
                bubble_w = 0;
                read_register_w = {16'd0,read_data[15:0]};
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
	else if (i_mem_write) begin
        case (i_funct3)
            // SB (need a special test for this instruction!!)
            3'b000: begin
                bubble_w = 0;
                sram_write = {i_write_data[7:0],8'd0};
                SRAM_UB = 0;
                SRAM_LB = 1;
            end
            // SH
            3'b001: begin
                bubble_w = 0;
                sram_write = i_write_data[15:0];
				SRAM_UB = 0;
                SRAM_LB = 0;
            end
            // SW
            3'b010: begin
				SRAM_UB = 0;
				SRAM_LB = 0;
                // represents second access to memory
                if (bubble_r) begin
                    sram_write = i_write_data[15:0];
                    bubble_w = 0;
                // represents first access to memory
				end
                else begin
                    sram_write = i_write_data[31:16];
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
always @ (posedge CLOCK_50 or negedge SW[0])begin 
    if(!SW[0]) begin
        bubble_r <= 0;
        read_register_r <= 32'd0;
    end
    else begin
        bubble_r <= bubble_w;
        read_register_r <= read_register_w;
    end
end

endmodule