// -----------------------------------------------------------------------------
// floating point division module
// -----------------------------------------------------------------------------

module fp_div (
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
reg  [4:0] count, next_count;
wire last_cycle;

// fraction multiplication signals
wire        [24:0] sub_in_a;
wire        [23:0] sub_in_b;
wire signed [24:0] sub_out;
reg  [48:0] shift_reg, next_shift_reg; // 24 + 25 bits

// output
reg  out_sign, next_out_sign;
wire [7:0]  exp_diff;
reg  [7:0]  out_exp, next_out_exp;
reg  [21:0] out_frac, next_out_frac;
reg  [31:0] result, next_result;

// wire assignments --------------------------------------------------
// last cycle signal
assign last_cycle = (count == 24); // one extra cycle

// adder
assign sub_in_a = shift_reg[48:24];
assign sub_in_b = {1'b1, b_frac};
assign sub_out = sub_in_a + sub_in_b;

// exponent
assign exp_diff = a_exp - b_exp; // note: exp_diff has same bit width

assign o_vaild = (state == DONE);
assign o_result = {out_sign, out_exp, out_frac};

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
        next_shift_reg = {1'b0, 1'b1, a_frac, 24'd0};
    end
    else begin
        if (state == CALC) begin
            next_shift_reg[0] = ~sub_out[24]; // sub_out sign negation
            next_shift_reg[24:1] = shift_reg[23:0];
            if (sub_out[24]) begin // sub result is negative
                next_shift_reg[48:25] = shift_reg[47:24];
            end
            else begin // sub result is positive
                next_shift_reg[48:25] = sub_out[23:0];
            end
        end
        else begin
            next_shift_reg = shift_reg;
        end
    end

    // next output
    // result
    if (last_cycle) begin // output in the next cycle
        next_out_sign = a_sign ^ b_sign;
        if (shift_reg[24]) begin
            next_out_exp = exp_diff;
            next_out_frac = shift_reg[24:1];
        end
        else begin
            next_out_exp = exp_diff - 1;
            next_out_frac = shift_reg[23:0];
        end
    end
    else begin
        next_out_sign = out_sign;
        next_out_exp = out_exp;
        next_out_frac = out_frac;
    end
end

// sequential always block -------------------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
         state <= IDLE;
         count <= 0;
         out_sign <= 0;
         out_exp <= 0;
         out_frac <= 0;
         shift_reg <= 0;
    end
    else begin
         state <= next_state;
         count <= next_count;
         out_sign <= next_out_sign;
         out_exp <= next_out_exp;
         out_frac <= next_out_frac;
         shift_reg <= next_shift_reg;
    end
end

endmodule
