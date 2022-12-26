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
parameter D10 = 7'b0001000;
parameter D11 = 7'b0000011;
parameter D12 = 7'b1000110;
parameter D13 = 7'b0100001;
parameter D14 = 7'b0000100;
parameter D15 = 7'b0001110;

always_comb begin
	case(i_rs[3:0])
		4'h0: o_seven_0 = D0;
		4'h1: o_seven_0 = D1;
		4'h2: o_seven_0 = D2;
		4'h3: o_seven_0 = D3;
		4'h4: o_seven_0 = D4;
		4'h5: o_seven_0 = D5;
		4'h6: o_seven_0 = D6;
		4'h7: o_seven_0 = D7;
		4'h8: o_seven_0 = D8;
		4'h9: o_seven_0 = D9;
		4'ha: o_seven_0 = D10;
		4'hb: o_seven_0 = D11;
		4'hc: o_seven_0 = D12;
		4'hd: o_seven_0 = D13;
		4'he: o_seven_0 = D14;
		4'hf: o_seven_0 = D15;
	endcase

	case(i_rs[7:4])
		4'h0: o_seven_1 = D0;
		4'h1: o_seven_1 = D1;
		4'h2: o_seven_1 = D2;
		4'h3: o_seven_1 = D3;
		4'h4: o_seven_1 = D4;
		4'h5: o_seven_1 = D5;
		4'h6: o_seven_1 = D6;
		4'h7: o_seven_1 = D7;
		4'h8: o_seven_1 = D8;
		4'h9: o_seven_1 = D9;
		4'ha: o_seven_1 = D10;
		4'hb: o_seven_1 = D11;
		4'hc: o_seven_1 = D12;
		4'hd: o_seven_1 = D13;
		4'he: o_seven_1 = D14;
		4'hf: o_seven_1 = D15;
	endcase
	
	case(i_rs[11:8])
		4'h0: o_seven_2 = D0;
		4'h1: o_seven_2 = D1;
		4'h2: o_seven_2 = D2;
		4'h3: o_seven_2 = D3;
		4'h4: o_seven_2 = D4;
		4'h5: o_seven_2 = D5;
		4'h6: o_seven_2 = D6;
		4'h7: o_seven_2 = D7;
		4'h8: o_seven_2 = D8;
		4'h9: o_seven_2 = D9;
		4'ha: o_seven_2 = D10;
		4'hb: o_seven_2 = D11;
		4'hc: o_seven_2 = D12;
		4'hd: o_seven_2 = D13;
		4'he: o_seven_2 = D14;
		4'hf: o_seven_2 = D15;
	endcase
	
	case(i_rs[15:12])
		4'h0: o_seven_3 = D0;
		4'h1: o_seven_3 = D1;
		4'h2: o_seven_3 = D2;
		4'h3: o_seven_3 = D3;
		4'h4: o_seven_3 = D4;
		4'h5: o_seven_3 = D5;
		4'h6: o_seven_3 = D6;
		4'h7: o_seven_3 = D7;
		4'h8: o_seven_3 = D8;
		4'h9: o_seven_3 = D9;
		4'ha: o_seven_3 = D10;
		4'hb: o_seven_3 = D11;
		4'hc: o_seven_3 = D12;
		4'hd: o_seven_3 = D13;
		4'he: o_seven_3 = D14;
		4'hf: o_seven_3 = D15;
	endcase

	case(i_rs[19:16])
		4'h0: o_seven_4 = D0;
		4'h1: o_seven_4 = D1;
		4'h2: o_seven_4 = D2;
		4'h3: o_seven_4 = D3;
		4'h4: o_seven_4 = D4;
		4'h5: o_seven_4 = D5;
		4'h6: o_seven_4 = D6;
		4'h7: o_seven_4 = D7;
		4'h8: o_seven_4 = D8;
		4'h9: o_seven_4 = D9;
		4'ha: o_seven_4 = D10;
		4'hb: o_seven_4 = D11;
		4'hc: o_seven_4 = D12;
		4'hd: o_seven_4 = D13;
		4'he: o_seven_4 = D14;
		4'hf: o_seven_4 = D15;
	endcase

	case(i_rs[23:20])
		4'h0: o_seven_5 = D0;
		4'h1: o_seven_5 = D1;
		4'h2: o_seven_5 = D2;
		4'h3: o_seven_5 = D3;
		4'h4: o_seven_5 = D4;
		4'h5: o_seven_5 = D5;
		4'h6: o_seven_5 = D6;
		4'h7: o_seven_5 = D7;
		4'h8: o_seven_5 = D8;
		4'h9: o_seven_5 = D9;
		4'ha: o_seven_5 = D10;
		4'hb: o_seven_5 = D11;
		4'hc: o_seven_5 = D12;
		4'hd: o_seven_5 = D13;
		4'he: o_seven_5 = D14;
		4'hf: o_seven_5 = D15;
	endcase

	case(i_rs[27:24])
		4'h0: o_seven_6 = D0;
		4'h1: o_seven_6 = D1;
		4'h2: o_seven_6 = D2;
		4'h3: o_seven_6 = D3;
		4'h4: o_seven_6 = D4;
		4'h5: o_seven_6 = D5;
		4'h6: o_seven_6 = D6;
		4'h7: o_seven_6 = D7;
		4'h8: o_seven_6 = D8;
		4'h9: o_seven_6 = D9;
		4'ha: o_seven_6 = D10;
		4'hb: o_seven_6 = D11;
		4'hc: o_seven_6 = D12;
		4'hd: o_seven_6 = D13;
		4'he: o_seven_6 = D14;
		4'hf: o_seven_6 = D15;
	endcase

	case(i_rs[31:28])
		4'h0: o_seven_7 = D0;
		4'h1: o_seven_7 = D1;
		4'h2: o_seven_7 = D2;
		4'h3: o_seven_7 = D3;
		4'h4: o_seven_7 = D4;
		4'h5: o_seven_7 = D5;
		4'h6: o_seven_7 = D6;
		4'h7: o_seven_7 = D7;
		4'h8: o_seven_7 = D8;
		4'h9: o_seven_7 = D9;
		4'ha: o_seven_7 = D10;
		4'hb: o_seven_7 = D11;
		4'hc: o_seven_7 = D12;
		4'hd: o_seven_7 = D13;
		4'he: o_seven_7 = D14;
		4'hf: o_seven_7 = D15;
	endcase
end

endmodule
