// -----------------------------------------------------------------------------
// shift operation module
// -----------------------------------------------------------------------------

module logic (
    input         i_mode, // 0: logical, 1: arithmetic (keep sign)
    input         i_direction, // 0: left, 1: right
    input  signed [31:0] i_a,
    input  signed [31:0] i_b,
    output signed [31:0] o_result
);

reg  [31:0] out;

assign o_result = out;

always @ (*) begin
    if (i_mode) begin // arithmetic ------------------------
        if (i_direction) begin // right 
	    out = i_a >>> i_b;
	end
	else begin // left
	    out = i_a <<< i_b;
	end
    end
    else begin // logical ----------------------------------
        if (i_direction) begin // right 
	    out = i_a >> i_b;
	end
	else begin // left
	    out = i_a << i_b;
	end
    end
end

endmodule
