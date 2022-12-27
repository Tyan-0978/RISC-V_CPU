// -----------------------------------------------------------------------------
// instruction memory (fake) module
// -----------------------------------------------------------------------------

module inst_mem #(parameter SIZE = 10) (
    input  [31:0] i_read_addr,
    output [31:0] o_read_data
);

reg  [31:0] memory [0:SIZE-1];
reg  [31:0] read_data;

integer i;

assign o_read_data = read_data;

always @(*) begin
    /*read_data = 32'dz;
    // read data
    for (i = 0; i < SIZE; i = i + 1) begin
        if (i_read_addr == i) read_data = memory[i];
    end*/
    case (i_read_addr)
        //0: read_data = memory[0];
        0: read_data = 32'h00A00593;
        1: read_data = 32'h00000613;
        2: read_data = 32'h00000693;
        3: read_data = 32'h00100713;
        4: read_data = 32'h00E687B3;
        5: read_data = 32'h00070693;
        6: read_data = 32'h00078713;
        7: read_data = 32'h00160613;
        8: read_data = 32'hFEB618E3;
        9: read_data = 32'h00070073;
	default: read_data = 0;
    endcase
end

endmodule
