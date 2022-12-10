// -----------------------------------------------------------------------------
// logic operation module
// -----------------------------------------------------------------------------

module logic (
    input  [1:0]  i_mode, // 0: AND, 1: OR, 2: XOR
    input  [31:0] i_a,
    input  [31:0] i_b,
    output [31:0] o_result
);

parameter AND_MODE = 0;
parameter OR_MODE  = 1;
parameter XOR_MODE = 2;

reg  [31:0] out;

assign o_result = out;

always @ (*) begin
    case (i_mode)
        AND_MODE: out = i_a & i_b;
        OR_MODE : out = i_a | i_b;
        XOR_MODE: out = i_a ^ i_b;
	default:  out = 0;
    endcase
end

endmodule
