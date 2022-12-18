// -----------------------------------------------------------------------------
// INT division module
// -----------------------------------------------------------------------------

module int_div (
    input  i_rst_n,
    input  i_clk,
    input  i_valid,
    output o_valid,

    input  signed [31:0] i_a,
    input  signed [31:0] i_b,
    output signed [31:0] o_quotient,
    output signed [31:0] o_remainder,
);

parameter IDLE = 0;
parameter CALC = 1;
parameter DONE = 2;

// wires & registers -------------------------------------------------

// control signals
reg  [1:0] state, next_state;
reg  [4:0] count, next_count;

// computation signals
wire        [31:0] sub_in_a, sub_in_b;
wire signed [32:0] sub_out; // 33 bits
reg         [61:0] shift_reg, next_shift_reg; // 31 + 31 bits

wire        reverse_quotient;
wire        remainder_mode;
wire [31:0] comp_remainder; // complement

// output
reg         valid, next_valid;
reg  [31:0] quotient , next_quotient;
reg  [31:0] remainder, next_remainder;

// wire assignments --------------------------------------------------

// subtractor
assign sub_in_a = shift_reg[61:30];
assign sub_in_b = {1'b0, i_b[30:0]};
assign sub_out = sub_in_a - sub_in_b;

// results
assign reverse_quotient = i_a[31] ^ i_b[31];
assign remainder_mode = {i_a[31], i_b[31]};
assign comp_remainder = i_b[30:0] - shift_reg[61:31];

// output
assign o_valid = valid;
assign o_quotient = quotient;
assign o_remainder = remainder;

// combinational always block ----------------------------------------

always @(*) begin
    // next control signals
    case (state)
        IDLE: begin
	    if (i_valid) begin
	        next_state = CALC;
	    end
	    else begin
	        next_state = state;
	    end
	    next_valid = 0;
	    next_count = 0;
	end
	CALC: begin
	    if (count == 30) begin
	        next_state = DONE;
	        next_valid = 1;
	    end
	    else begin
	        next_state = state;
	        next_valid = 0;
	    end
	    next_valid = 0;
	    next_count = count + 1;
	end
	DONE: begin
	    if (i_valid) begin
	        next_state = CALC;
	    end
	    else begin
	        next_state = state;
	    end
	    next_valid = 1;
	    next_count = 0;
	end
	default: begin
	    next_state = IDLE;
	    next_valid = 0;
	    next_count = 0;
	end
    endcase

    // next shift register
    if (i_valid) begin
        next_shift_reg = {31'd0, i_a[30:0]};
    end
    else begin
        if (state == CALC) begin
            next_shift_reg[0] = ~sub_out[32];
	    next_shift_reg[30:1] = shift_reg[29:0]; // left shift
	    if (sub_out[32]) begin // sub result is negative; shift
		next_shift_reg[61:31] = shift_reg[60:30];
	    end
	    else begin // use sub result
		next_shift_reg[61:31] = sub_out[30:0];
	    end
	end
	else begin
	    next_shift_reg = shift_reg;
	end
    end

    // next output
    if (state == DONE) begin
        // example of results for different sign mode
        //  7 /  3 =  2 ...  1
        //  7 / -3 = -3 ... -2
        // -7 /  3 = -3 ...  2
        // -7 / -3 =  2 ... -1
        next_quotient  = {{reverse_quotient}} ^ {1'b0, shift_reg[30:0]};
        case (remainder_mode)
            2'b00: next_remainder = shift_reg[61:31];
            2'b01: next_remainder = (~comp_remainder) + 1;
            2'b10: next_remainder = comp_remainder;
            2'b11: next_remainder = (~shift_reg[61:31]) + 1;
        endcase
    end
    else begin
        next_quotient  = 0;
        next_remainder = 0;
    end
end

// sequential always block -------------------------------------------

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
	state <= IDLE;
        valid <= 0;
	count <= 0;
	quotient  <= 0;
	remainder <= 0;
	shift_reg <= 0;
    end
    else begin
	state <= next_state;
        valid <= next_valid;
	count <= next_count;
	quotient  <= next_quotient;
	remainder <= next_remainder;
	shift_reg <= next_shift_reg;
    end
end

endmodule
