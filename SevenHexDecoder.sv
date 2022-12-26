module SevenHexDecoder (
	input        [31:0] i_rs,
	output logic [6:0] o_seven_0,
	output logic [6:0] o_seven_1,
	output logic [6:0] o_seven_2,
	output logic [6:0] o_seven_3,
	output logic [6:0] o_seven_4,
	output logic [6:0] o_seven_5,
	output logic [6:0] o_seven_6,
	output logic [6:0] o_seven_7
);

/* The layout of seven segment display, 1: dark
 *    00
 *   5  1
 *    66
 *   4  2
 *    33
 */
parameter D0 = 7'b1000000;
parameter D1 = 7'b1111001;
parameter D2 = 7'b0100100;
parameter D3 = 7'b0110000;
parameter D4 = 7'b0011001;
parameter D5 = 7'b0010010;
parameter D6 = 7'b0000010;
parameter D7 = 7'b1011000;
parameter D8 = 7'b0000000;
parameter D9 = 7'b0010000;
always_comb begin
	case(i_hex_1)
		4'h0: begin o_seven_ten_1 = D0; o_seven_one_1 = D0; end
		4'h1: begin o_seven_ten_1 = D0; o_seven_one_1 = D1; end
		4'h2: begin o_seven_ten_1 = D0; o_seven_one_1 = D2; end
		4'h3: begin o_seven_ten_1 = D0; o_seven_one_1 = D3; end
		4'h4: begin o_seven_ten_1 = D0; o_seven_one_1 = D4; end
		4'h5: begin o_seven_ten_1 = D0; o_seven_one_1 = D5; end
		4'h6: begin o_seven_ten_1 = D0; o_seven_one_1 = D6; end
		4'h7: begin o_seven_ten_1 = D0; o_seven_one_1 = D7; end
		4'h8: begin o_seven_ten_1 = D0; o_seven_one_1 = D8; end
		4'h9: begin o_seven_ten_1 = D0; o_seven_one_1 = D9; end
		4'ha: begin o_seven_ten_1 = D1; o_seven_one_1 = D0; end
		4'hb: begin o_seven_ten_1 = D1; o_seven_one_1 = D1; end
		4'hc: begin o_seven_ten_1 = D1; o_seven_one_1 = D2; end
		4'hd: begin o_seven_ten_1 = D1; o_seven_one_1 = D3; end
		4'he: begin o_seven_ten_1 = D1; o_seven_one_1 = D4; end
		4'hf: begin o_seven_ten_1 = D1; o_seven_one_1 = D5; end
	endcase
	
	case(i_hex_2)
		4'h0: begin o_seven_ten_2 = D0; o_seven_one_2 = D0; end
		4'h1: begin o_seven_ten_2 = D0; o_seven_one_2 = D1; end
		4'h2: begin o_seven_ten_2 = D0; o_seven_one_2 = D2; end
		4'h3: begin o_seven_ten_2 = D0; o_seven_one_2 = D3; end
		4'h4: begin o_seven_ten_2 = D0; o_seven_one_2 = D4; end
		4'h5: begin o_seven_ten_2 = D0; o_seven_one_2 = D5; end
		4'h6: begin o_seven_ten_2 = D0; o_seven_one_2 = D6; end
		4'h7: begin o_seven_ten_2 = D0; o_seven_one_2 = D7; end
		4'h8: begin o_seven_ten_2 = D0; o_seven_one_2 = D8; end
		4'h9: begin o_seven_ten_2 = D0; o_seven_one_2 = D9; end
		4'ha: begin o_seven_ten_2 = D1; o_seven_one_2 = D0; end
		4'hb: begin o_seven_ten_2 = D1; o_seven_one_2 = D1; end
		4'hc: begin o_seven_ten_2 = D1; o_seven_one_2 = D2; end
		4'hd: begin o_seven_ten_2 = D1; o_seven_one_2 = D3; end
		4'he: begin o_seven_ten_2 = D1; o_seven_one_2 = D4; end
		4'hf: begin o_seven_ten_2 = D1; o_seven_one_2 = D5; end
	endcase
	
	case(i_hex_3)
		4'h0: begin o_seven_ten_3 = D0; o_seven_one_3 = D0; end
		4'h1: begin o_seven_ten_3 = D0; o_seven_one_3 = D1; end
		4'h2: begin o_seven_ten_3 = D0; o_seven_one_3 = D2; end
		4'h3: begin o_seven_ten_3 = D0; o_seven_one_3 = D3; end
		4'h4: begin o_seven_ten_3 = D0; o_seven_one_3 = D4; end
		4'h5: begin o_seven_ten_3 = D0; o_seven_one_3 = D5; end
		4'h6: begin o_seven_ten_3 = D0; o_seven_one_3 = D6; end
		4'h7: begin o_seven_ten_3 = D0; o_seven_one_3 = D7; end
		4'h8: begin o_seven_ten_3 = D0; o_seven_one_3 = D8; end
		4'h9: begin o_seven_ten_3 = D0; o_seven_one_3 = D9; end
		4'ha: begin o_seven_ten_3 = D1; o_seven_one_3 = D0; end
		4'hb: begin o_seven_ten_3 = D1; o_seven_one_3 = D1; end
		4'hc: begin o_seven_ten_3 = D1; o_seven_one_3 = D2; end
		4'hd: begin o_seven_ten_3 = D1; o_seven_one_3 = D3; end
		4'he: begin o_seven_ten_3 = D1; o_seven_one_3 = D4; end
		4'hf: begin o_seven_ten_3 = D1; o_seven_one_3 = D5; end
	endcase
end

endmodule
