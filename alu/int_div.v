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
    output signed [31:0] o_remainder
);

parameter IDLE = 0;
parameter CALC = 1;
parameter DONE = 2;

// wires & registers -------------------------------------------------
// control signals
reg  [1:0] state, next_state;
reg  [4:0] count, next_count;
wire last_cycle;

// computation signals
wire        [30:0] val_a, val_b;
wire        [31:0] sub_in_a, sub_in_b;
wire signed [32:0] sub_out; // 33 bits
reg         [61:0] shift_reg, next_shift_reg; // 31 + 31 bits

wire        reverse_quotient;
wire [ 1:0] remainder_mode;
wire [31:0] comp_remainder; // complement

// output
reg  [31:0] quotient , next_quotient;
reg  [31:0] remainder, next_remainder;

// wire assignments --------------------------------------------------
assign last_cycle = (count == 31);

// input values
assign val_a = (i_a[31]) ? (~i_a[30:0]) + 1 : i_a[30:0];
assign val_b = (i_b[31]) ? (~i_b[30:0]) + 1 : i_b[30:0];

// subtractor
assign sub_in_a = shift_reg[61:30];
assign sub_in_b = {1'b0, val_b};
assign sub_out = sub_in_a - sub_in_b;

// results
assign reverse_quotient = i_a[31] ^ i_b[31];
assign remainder_mode = {i_a[31], i_b[31]};
assign comp_remainder = val_b - shift_reg[61:31];

// output
assign o_valid = (state == DONE);
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
	    next_count = 0;
	end
	CALC: begin
	    if (last_cycle) begin
	        next_state = DONE;
	    end
	    else begin
	        next_state = state;
	    end
	    next_count = count + 1;
	end
	DONE: begin
	    if (i_valid) begin
	        next_state = CALC;
	    end
	    else begin
	        next_state = state;
	    end
	    next_count = 0;
	end
	default: begin
	    next_state = IDLE;
	    next_count = 0;
	end
    endcase

    // next shift register
    if (i_valid) begin
        next_shift_reg = {31'd0, val_a};
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
    if (last_cycle) begin
        // example of results for different sign mode
        //  7 /  3 =  2 ...  1
        //  7 / -3 = -3 ... -2
        // -7 /  3 = -3 ...  2
        // -7 / -3 =  2 ... -1
        next_quotient  = {32{reverse_quotient}} ^ {1'b0, shift_reg[30:0]};
        case (remainder_mode)
            2'b00: next_remainder = shift_reg[61:31];
            2'b01: next_remainder = (~comp_remainder) + 1;
            2'b10: next_remainder = comp_remainder;
            2'b11: next_remainder = (~shift_reg[61:31]) + 1;
        endcase
    end
    else begin
        next_quotient  = quotient;
        next_remainder = remainder;
    end
end

// sequential always block -------------------------------------------

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
	state <= IDLE;
	count <= 0;
	quotient  <= 0;
	remainder <= 0;
	shift_reg <= 0;
    end
    else begin
	state <= next_state;
	count <= next_count;
	quotient  <= next_quotient;
	remainder <= next_remainder;
	shift_reg <= next_shift_reg;
    end
end

endmodule
