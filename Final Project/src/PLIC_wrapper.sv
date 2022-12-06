`include "AXI_def.svh"

module PLIC_wrapper (

    input                               clk,
    input                               rst,

    //READ ADDRESS
    input [7:0]                         ARId,
    input [`AXI_ADDR_BITS-1:0]          ARAddr,
    input [`AXI_LEN_BITS-1:0]           ARLen,
    input [`AXI_SIZE_BITS-1:0]          ARSize,
    input [1:0]                         ARBurst,
    input                               ARValid,
    output logic                        ARReady,
    //READ DATA
    output logic [7:0]                  RId,
    output logic [`AXI_DATA_BITS-1:0]   RData,
    output logic [1:0]                  RResp,
    output logic                        RLast,
    output logic                        RValid,
    input                               RReady,
    //WRITE ADDRESS
    input [7:0]                         AWId,
    input [`AXI_ADDR_BITS-1:0]          AWAddr,
    input [`AXI_LEN_BITS-1:0]           AWLen,
    input [`AXI_SIZE_BITS-1:0]          AWSize,
    input [1:0]                         AWBurst,
    input                               AWValid,
    output logic                        AWReady,
    //WRITE DATA
    input [`AXI_DATA_BITS-1:0]          WData,
    input [`AXI_STRB_BITS-1:0]          WStrb,
    input                               WLast,
    input                               WValid,
    output logic                        WReady,
    //WRITE RESPONSE
    output logic [7:0]                  BId,
    output logic [1:0]                  BResp,
    output logic                        BValid,
    input                               BReady,
    // interrupt
    input           sensor_pend,
    input           dma_pend,
    input           tpu_pend,
    output logic    pend_toCPU
);

localparam  State_Idle         = 2'd0;
localparam  State_RValid       = 2'd1;
localparam  State_WValid       = 2'd2;
localparam  State_BValid       = 2'd3;

localparam  inter_src   = 2'd1;
localparam  en          = 2'd2;

localparam  sensor         = 0;
localparam  dma            = 1;
localparam  tpu            = 2;

logic [1:0]     state, next_state;
logic [2:0]     plic_en, plic_src;
logic [1:0]     plic_idx;
logic [13:0]    plic_addr, plic_addr_reg;

// plic addr decode
always_comb begin
    if(plic_addr[2]) // 0x000004: plic_src
        plic_idx = 2'd1;
    else if(plic_addr[13])  // 0x002000: interrupt enable bits -> 2
        plic_idx = 2'd2;
    else
        plic_idx = 2'd0;
end

// write plic register file
always_ff @(posedge clk) begin
    if(rst) begin
        plic_en <= 3'd0;
    end
    else if(plic_idx == en) begin
        plic_en <= WData[2:0];
    end
end

// write plic register file
always_ff @(posedge clk) begin
    if(rst)
        RData <= 64'd0;
    else begin
        if(plic_idx == inter_src)
            RData <= {61'd0, plic_src};
        else
            RData <= 64'd0;
    end
end

always_ff @(posedge clk) begin
    if(rst) begin
        pend_toCPU <= 1'b0;
    end
    else begin
        if(sensor_pend && plic_en[sensor]) begin
            pend_toCPU <= 1'b1;
            plic_src <= 3'd0;
        end
        else if(dma_pend && plic_en[dma]) begin
            pend_toCPU <= 1'b1;
            plic_src <= 3'd1;
        end
        else if(tpu_pend && plic_en[tpu]) begin
            pend_toCPU <= 1'b1;
            plic_src <= 3'd2;
        end
        else begin // no interrupt
            pend_toCPU <= 1'b0;
            plic_src <= 3'd3;
        end
    end
end

/* State Machine */
always_ff @( posedge clk or posedge rst) begin
    if (rst) begin
        state <= State_Idle;
    end
    else begin
        state <= next_state;        
    end
end
always_comb begin
    case (state)
    State_Idle: begin
        if (ARValid) begin
            next_state = State_RValid;
        end
        else if (AWValid) begin
            if (WValid) begin
                next_state = State_BValid;
            end
            else begin
                next_state = State_WValid;
            end
        end
        else begin
            next_state = State_Idle;
        end
    end
    State_RValid: begin
        if (RReady) begin
            next_state = State_Idle;
        end
        else begin
            next_state = State_RValid;
        end
    end
    State_WValid: begin
        if(WValid) begin
            next_state = State_BValid;
        end
        else begin
            next_state = State_WValid;
        end
    end
    State_BValid: begin
        if (!BReady) begin
            next_state = State_BValid;
        end
        else begin
            next_state = State_Idle;
        end        
    end
    endcase
end

always_comb begin
    case(state)
        State_Idle: begin
            if (ARValid & ARReady) 
                plic_addr = ARAddr[13:0];
            else if (AWValid & AWReady)
                plic_addr = AWAddr[13:0];
            else
                plic_addr = 14'd0;
        end
        State_RValid, State_WValid: begin
            plic_addr = plic_addr_reg;
        end
        State_BValid: begin
            plic_addr = 14'd0;
        end
    endcase
end

always_ff @( posedge clk ) begin
    if (rst) begin
        plic_addr_reg <= 14'd0;
    end
    else begin
        if (ARReady & ARValid) begin
            plic_addr_reg <= ARAddr[13:0];
        end
        else if (AWReady & AWValid) begin
            plic_addr_reg <= AWAddr[13:0];     
        end
    end
end

/* Global Signal */
assign RResp = `AXI_RESP_OKAY;
assign BResp = `AXI_RESP_OKAY;

/* AR R Channel */
assign  ARReady = (ARValid && state == State_Idle);

always_ff @( posedge clk ) begin
    if (rst) begin
        RId <= 8'd0;
    end
    else if (ARValid & ARReady) begin
        RId <= ARId;
    end
end

assign RValid = (state == State_RValid);
assign RLast  = (state == State_RValid);

/* AW W B Channel */
assign  AWReady = (AWValid && state == State_Idle);
assign  WReady = (state == State_WValid || (state == State_Idle && WValid));
assign  BValid = (state == State_BValid);

always_ff @( posedge clk ) begin
    if (rst) begin
        BId <= 8'd0;
    end
    else if (AWValid & AWReady) begin
        BId <= AWId;
    end
end

endmodule
