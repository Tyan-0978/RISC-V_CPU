// -----------------------------------------------------------------------------
// INT multiplication module
// -----------------------------------------------------------------------------

module int_mul (
    input  i_rst_n,
    input  i_clk,
    input  i_valid,
    output o_valid,

    input  signed [31:0] i_a,
    input  signed [31:0] i_b,
    output signed [31:0] o_result
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
wire out_sign;
wire [30:0] add_in_a, add_in_b;
wire [31:0] add_out;
reg  [61:0] shift_reg, next_shift_reg; // 31 + 31 bits
reg  [31:0] result, next_result;

// wire assignments --------------------------------------------------
assign out_sign = i_a[31] ^ i_b[31];
assign last_cycle = (count == 31);

// adder
assign add_in_a = i_a[30:0] & {31{shift_reg[0]}};
assign add_in_b = shift_reg[61:31];
assign add_out = add_in_a + add_in_b;

// output
assign o_valid = (state == DONE);
assign o_result = result;

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
	        next_state = IDLE;
	    end
	end
	default: begin
	    next_state = IDLE;
	    next_count = 0;
	end
    endcase

    // next shift register
    if (i_valid) begin
        next_shift_reg = {32'd0, i_b[30:0]};
    end
    else begin
        if (state == CALC) begin
	    next_shift_reg[29:0] = shift_reg[30:1];
	    next_shift_reg[61:30] = add_out;
	end
	else begin
	    next_shift_reg = shift_reg;
	end
    end

    // next output
    if (last_cycle) begin
        next_result = {out_sign, shift_reg[30:0]};
    end
    else begin
        next_result = 0;
    end
end

// sequential always block -------------------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
	state <= IDLE;
	count <= 0;
	result <= 0;
	shift_reg <= 0;
    end
    else begin
	state <= next_state;
	count <= next_count;
	result <= next_result;
	shift_reg <= next_shift_reg;
    end
end

endmodule
