// -----------------------------------------------------------------------------
// comparison module
// -----------------------------------------------------------------------------

module comp (
    input        i_eq,   // 0: without equal, 1: with equal
    input  [1:0] i_mode, // 00: <, 01: >, 1x: ==
    input  signed [31:0] i_a,
    input  signed [31:0] i_b,
    output [31:0] o_result
);

wire is_equal;
reg  result;

assign is_equal = (i_a == i_b);
assign is_smaller = (i_a < i_b);
assign o_result = {31'd0, result};

always @(*) begin
    case (i_mode)
        2'b00: begin
            if (i_eq) result = (is_smaller) | is_equal;
            else      result = is_smaller;
        end
        2'b01: begin
            if (i_eq) result = (~is_smaller) | is_equal;
            else      result = ~is_smaller;
        end
        2'b10: begin
            if (i_eq) result = is_equal;
            else      result = ~is_equal;
        end
        default: result = 0;
    endcase
end

endmodule
