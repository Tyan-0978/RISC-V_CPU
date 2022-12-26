// -----------------------------------------------------------------------------
// instruction memory (fake) module
// -----------------------------------------------------------------------------

module inst_mem #(SIZE = 64) (
    input  [31:0] i_read_addr,
    output [31:0] o_read_data
);

reg  [31:0] memory [0:SIZE-1];
reg  [31:0] read_data;

always @(*) begin
    // read data
    for (int i = 0; i < SIZE; i = i + 1) begin
        if (i_read_addr == i) read_data = memory[i];
        else                  read_data = 31'dz;
    end
    
    // memory
    memory[0] = 32'h00A00593;
    memory[1] = 32'h00058073;
    for (int i = 2; i < SIZE; i = i + 1) begin
        memory[i] = 0;
    end
end

endmodule
