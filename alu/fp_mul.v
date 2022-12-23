// -----------------------------------------------------------------------------
// floating point multiplication module
// -----------------------------------------------------------------------------

module fp_mul (
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
// FP decoding
wire        a_sign, b_sign;
wire [7:0]  a_exp , b_exp;
wire [22:0] a_frac, b_frac;

// control signals
reg  [1:0] state, next_state;
reg        valid, next_vaild;
reg  [4:0] count, next_count;
wire last_cycle;

// fraction multiplication signals
wire [23:0] add_in_a, add_in_b;
wire [24:0] add_out;
reg  [47:0] shift_reg, next_shift_reg;

// output
wire out_sign;
wire [7:0]  exp_sum;
reg  [7:0]  out_exp, next_out_exp;
reg  [21:0] out_frac, next_out_frac;

// wire assignments --------------------------------------------------
// last cycle signal
assign last_cycle = (count == 23);
// adder
assign add_in_a = {1'b1, a_frac} & {{shift_reg[0]}};
assign add_in_b = shift_reg[47:24];
assign add_out = add_in_a + add_in_b;

// output 
assign out_sign = a_sign ^ b_sign;
assign exp_sum = a_exp + b_exp; // note: exp_sum has same bit width

assign o_vaild = valid;
assign o_result = {out_sign, out_exp, out_frac}

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
            if (last_cycle) begin
                next_state = DONE;
                next_valid = 1;
            end
            else begin
                next_state = state;
                next_valid = 0;
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
        next_shift_reg = {24'd0, 1'b1, b_frac};
    end
    else begin
        if (state == CALC) begin
            next_shift_reg[22:0] = shift_reg[23:1];
            next_shift_reg[47:23] = add_out;
        end
        else begin
            next_shift_reg = shift_reg;
        end
    end

    // next output
    if (last_cycle) begin
        if (shift_reg[47]) begin // carry
            next_out_frac = shift_reg[46:24];
            next_out_exp = exp_sum + 1;
        end
        else begin
            next_out_frac = shift_reg[45:23];
            next_out_exp = exp_sum;
        end
    end
    else begin
        next_out_frac = out_frac;
        next_out_exp = out_exp;
    end
end

// sequential always block -------------------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
         state <= IDLE;
         valid <= 0;
         out_frac <= 0;
         shift_reg <= 0;
    end
    else begin
         state <= next_state;
         valid <= next_valid;
         out_frac <= next_out_frac;
         shift_reg <= next_shift_reg;
    end
end

endmodule
