module ecall (
    input 
    
    
    
    )
always_comb begin
    if (!avm_waitrequest) begin
        case (state_r)
            S_GET_REFERENCE: begin
                if (avm_address_r == STATUS_BASE) begin
                    ref_w = ref_r;
                    read_w = read_r;
                    result_w = result_r;
                    state_w = state_r;
                    bytes_counter_w = bytes_counter_r;
                    SW_start_w = SW_start_r;
                    if (avm_readdata[RX_OK_BIT]) begin
                        StartRead(RX_BASE);
                    end
                    else begin
                        StartRead(avm_address_r);
                    end
                end

                else if (avm_address_r == RX_BASE) begin
                    StartRead(STATUS_BASE);
                    read_w = read_r;
                    result_w = result_r;
                    SW_start_w = SW_start_r;
                    ref_w = avm_readdata[7:0] + (ref_r << 8); 
                    
                    if (bytes_counter_r == 31) begin
                        bytes_counter_w = 0;
                        state_w = S_GET_READ;
                    end
                    else begin
                        bytes_counter_w = bytes_counter_r + 1;
                        state_w = state_r;
                    end
                end

                
                else begin 
                    ref_w = ref_r;
                    read_w = read_r;
                    result_w = result_r;
                    avm_write_w = 0;
                    state_w = state_r;
                    bytes_counter_w = bytes_counter_r;
                    SW_start_w = SW_start_r;
                    avm_read_w = 0;
                    avm_address_w = avm_address_r;
                end
            end

            S_GET_READ: begin
                if (avm_address_r == STATUS_BASE) begin
                    ref_w = ref_r;
                    read_w = read_r;
                    result_w = result_r;
                    state_w = state_r;
                    bytes_counter_w = bytes_counter_r;
                    SW_start_w = SW_start_r;
                    if (avm_readdata[RX_OK_BIT])
                        StartRead(RX_BASE);
                    else
                        StartRead(avm_address_r);
                end

                else if (avm_address_r == RX_BASE) begin
                    StartRead(STATUS_BASE);
                    read_w = avm_readdata[7:0] + (read_r << 8); // TBM
                    ref_w = ref_r;
                    result_w = result_r;

                    if (bytes_counter_r == 31) begin
                        state_w = S_WAIT_CALCULATE;                    
                        SW_start_w = 1;
                        bytes_counter_w = 0;
                    end
                    else begin
                        state_w = state_r;
                        SW_start_w = SW_start_r;
                        bytes_counter_w = bytes_counter_r + 1;
                    end  
                end
                else begin 
                    ref_w = ref_r;
                    read_w = read_r;
                    result_w = result_r;
                    avm_write_w = 0;
                    state_w = state_r;
                    bytes_counter_w = bytes_counter_r;
                    SW_start_w = SW_start_r;
                    avm_read_w = 0;
                    avm_address_w = avm_address_r;
                end
            end

            S_WAIT_CALCULATE: begin
                ref_w = ref_r;
                read_w = read_r;
                avm_read_w = 1;
                avm_write_w = 0;
                SW_start_w = 0;
                bytes_counter_w = bytes_counter_r;
                avm_address_w = avm_address_r;
                if (SW_finished && !SW_start_r) begin
                    state_w = S_SEND_RESULT;
                    result_w = {120'b0, column, 57'b0, row, 54'b0, alignment_score};
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
                    SW_start_w = 0;
                    if (avm_readdata[TX_OK_BIT])
                        StartWrite(TX_BASE);
                    else
                        StartRead(avm_address_r);
                end

                else if (avm_address_r == TX_BASE) begin
                    ref_w = ref_r;
                    read_w = 0;
                    SW_start_w = 0;
                    StartRead(STATUS_BASE);
                    if (bytes_counter_r == 30) begin
                        result_w = 0;
                        state_w = S_GET_REFERENCE;  
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
                    SW_start_w = SW_start_r;
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
        SW_start_w = 0;
        bytes_counter_w = bytes_counter_r;
        avm_address_w = avm_address_r;
        if (SW_finished && !SW_start_r) begin
            state_w = S_SEND_RESULT;
            result_w = {120'b0, column, 57'b0, row, 54'b0, alignment_score};
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
        SW_start_w = SW_start_r;
    end
end

endmodule