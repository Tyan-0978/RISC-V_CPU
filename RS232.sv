module RS232(
    input         avm_rst,
    input         avm_clk,
    output  [4:0] avm_address,
    output        avm_read,
    input  [31:0] avm_readdata,
    output        avm_write,
    output [31:0] avm_writedata,
    input         avm_waitrequest
);

localparam RX_BASE     = 0*4;
localparam TX_BASE     = 1*4;
localparam STATUS_BASE = 2*4;
localparam TX_OK_BIT   = 6;
localparam RX_OK_BIT   = 7;

// localparam S_GET_REFERENCE = 0;
// localparam S_GET_READ = 1;
localparam S_WAIT_CALCULATE = 2;
localparam S_SEND_RESULT = 3;

logic [31:0] result_r, result_w;
logic [1:0] state_r, state_w;
logic [6:0] bytes_counter_r, bytes_counter_w;
logic [4:0] avm_address_r, avm_address_w;
logic avm_read_r, avm_read_w, avm_write_r, avm_write_w;

logic calculation_start_r, calculation_start_w;
logic calculation_finished;
logic [31:0] answer;

logic rst_n;

assign avm_address = avm_address_r;
assign avm_read = avm_read_r;
assign avm_write = avm_write_r;
assign avm_writedata = result_r[247-:8];

cpu core_cpu(
    .i_rst_n(rst_n),
    .i_clk(avm_clk),
    .i_start(calculation_start_r),
    .o_ecall_ready(calculation_finished),
    .o_ecall_data(answer)
);



always@(*) begin
    rst_n = !avm_rst;
    if (!avm_waitrequest) begin
        case (state_r)
            S_WAIT_CALCULATE: begin
                ref_w = ref_r;
                read_w = read_r;
                avm_read_w = 1;
                avm_write_w = 0;
                calculation_start_w = 0;
                bytes_counter_w = bytes_counter_r;
                avm_address_w = avm_address_r;
                if (calculation_finished && !calculation_start_r) begin
                    state_w = S_SEND_RESULT;
                    result_w = answer; //
                end
                else begin
                    state_w = state_r;
                    result_w = result_r;
                end
            end
            
            S_SEND_RESULT: begin
                if (avm_address_r == STATUS_BASE) begin
                    ref_w = ref_r;
                    read_w = 0;
                    result_w = result_r;
                    state_w = state_r;
                    bytes_counter_w = bytes_counter_r;
                    calculation_start_w = 0;
                    if (avm_readdata[TX_OK_BIT])
                        StartWrite(TX_BASE);
                    else
                        StartRead(avm_address_r);
                end

                else if (avm_address_r == TX_BASE) begin
                    ref_w = ref_r;
                    read_w = 0;
                    calculation_start_w = 0;
                    StartRead(STATUS_BASE);
                    if (bytes_counter_r == 30) begin
                        result_w = 0;
                        state_w = S_WAIT_CALCULATE;  //
                        bytes_counter_w = 0;                  
                    end
                    else begin
                        result_w = result_r << 8;
                        state_w = state_r;    
                        bytes_counter_w = bytes_counter_r + 1;
                    end
                end
                else begin 
                    ref_w = ref_r;
                    read_w = read_r;
                    result_w = result_r;
                    avm_write_w = avm_write_r;
                    state_w = state_r;
                    bytes_counter_w = bytes_counter_r;
                    calculation_start_w = calculation_start_r;
                    avm_read_w = avm_read_r;
                    avm_address_w = avm_address_r;
                end
            end
        
        endcase
    end

    else if ((state_r == S_WAIT_CALCULATE) && avm_waitrequest) begin
        ref_w = ref_r;
        read_w = read_r;
        avm_read_w = 1;
        avm_write_w = 0;
        calculation_start_w = 0;
        bytes_counter_w = bytes_counter_r;
        avm_address_w = avm_address_r;
        if (calculation_finished && !calculation_start_r) begin
            state_w = S_SEND_RESULT;
            result_w = answer; //
        end
        else begin
            state_w = state_r;
            result_w = result_r;
        end
    end
    
    else begin
        ref_w = ref_r;
        read_w = read_r;
        result_w = result_r;
        avm_read_w = avm_read_r;
        avm_write_w = avm_write_r;
        bytes_counter_w = bytes_counter_r;
        avm_address_w = avm_address_r;
        state_w = state_r;
        calculation_start_w = calculation_start_r;
    end
end

always @(posedge avm_clk or posedge avm_rst) begin
    if (avm_rst) begin
        ref_r <= 0;
        read_r <= 0;
        result_r <= 0;
        avm_address_r <= STATUS_BASE;
        avm_read_r <= 1;
        avm_write_r <= 0;
        state_r <= S_WAIT_CALCULATE; //
        bytes_counter_r <= 0;
        calculation_start_r <= 0;
    end else begin
        ref_r <= ref_w;
        read_r <= read_w;
        result_r <= result_w;
        avm_address_r <= avm_address_w;
        avm_read_r <= avm_read_w;
        avm_write_r <= avm_write_w;
        state_r <= state_w;
        bytes_counter_r <= bytes_counter_w;
        calculation_start_r <= calculation_start_w;
    end
end

endmodule