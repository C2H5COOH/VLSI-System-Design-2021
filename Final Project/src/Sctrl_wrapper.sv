`include "AXI_def.svh"

module Sctrl_wrapper (
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

    input  [31:0]                       dataFromSCtrl,
    output logic                        enableSCtrl,
    output logic                        clearSCtrl,
    output logic [5:0]                  addrToSCtrl
);
typedef enum logic {
    Slave_IdleR,
    Slave_RValid
} AXI_SlaveStateR;

typedef enum logic[1:0] {
    Slave_IdleW,
    Slave_WReady,
    Slave_BValid
} AXI_SlaveStateW;

AXI_SlaveStateR cStateSCtrlR, nStateSCtrlR;
AXI_SlaveStateW cStateSCtrlW, nStateSCtrlW;

logic [`AXI_ADDR_BITS-1:0]          AWAddr_reg;

/* State Machines */
always_ff @( posedge clk or posedge rst) begin
    if (rst) begin
        cStateSCtrlR <= Slave_IdleR;
        cStateSCtrlW <= Slave_IdleW;
    end
    else begin
        cStateSCtrlR <= nStateSCtrlR;
        cStateSCtrlW <= nStateSCtrlW;        
    end
end
/** R **/
always_comb begin
    case (cStateSCtrlR)
    Slave_IdleR: begin
        if (ARValid) begin
            nStateSCtrlR = Slave_RValid;
        end
        else begin
            nStateSCtrlR = Slave_IdleR;
        end
    end
    Slave_RValid: begin
        if (RReady) begin
            nStateSCtrlR = Slave_IdleR;
        end
        else begin
            nStateSCtrlR = Slave_RValid;
        end
    end
    endcase
end

/** W **/
always_comb begin
    case (cStateSCtrlW)
    Slave_IdleW: begin
        if (AWValid) begin
            if (WValid) begin
                nStateSCtrlW = Slave_BValid;
            end
            else begin
                nStateSCtrlW = Slave_WReady;
            end
        end
        else begin
            nStateSCtrlW = Slave_IdleW;
        end
    end
    Slave_WReady: begin
        if(WValid) begin
            nStateSCtrlW = Slave_BValid;
        end
        else begin
            nStateSCtrlW = Slave_WReady;
        end
    end
    Slave_BValid: begin
        if (!BReady) begin
            nStateSCtrlW = Slave_BValid;
        end
        else begin
            nStateSCtrlW = Slave_IdleW;
        end        
    end
    default: begin
        nStateSCtrlW = Slave_IdleW;
    end
    endcase
end

/* Read address */
always_comb begin
    addrToSCtrl = ARAddr[7:2];
end

/* Global Signal */
assign RResp = `AXI_RESP_OKAY;
assign BResp = `AXI_RESP_OKAY;

/* AR R Channel */
assign  ARReady = (ARValid && cStateSCtrlR == Slave_IdleR);
always_ff @( posedge clk ) begin
    if (rst) begin
        RId <= 8'd0;
    end
    else if (ARValid & ARReady) begin
        RId <= ARId;
    end
end
assign RValid = (cStateSCtrlR == Slave_RValid);
assign RLast  = 1'b1;
always_ff @(posedge clk) begin
    if (rst) begin
        RData <= `AXI_DATA_BITS'd0;
    end
    else begin
        RData <= {32'd0, dataFromSCtrl};
    end
end

/* AW W B Channel */
assign  AWReady = (AWValid && cStateSCtrlW == Slave_IdleW);
assign  WReady = (cStateSCtrlW == Slave_WReady || (cStateSCtrlW == Slave_IdleW && WValid));
always_ff @( posedge clk ) begin
    if (rst) begin
        BId <= 8'd0;
        AWAddr_reg <= `AXI_ADDR_BITS'd0;
    end
    else if (AWValid & AWReady) begin
        BId <= AWId;
        AWAddr_reg <= AWAddr;
    end
end
always_comb begin
    if (cStateSCtrlW == Slave_BValid) begin
        BValid = 1'b1;
    end
    else begin
        BValid = 1'b0;
    end
end
always_ff @(posedge clk) begin
    if (rst) begin
        enableSCtrl <= 1'b0;
    end
    else if (WValid && 
             ((cStateSCtrlW == Slave_IdleW && AWAddr == `AXI_ADDR_BITS'h100) ||
              (cStateSCtrlW == Slave_WReady && AWAddr_reg == `AXI_ADDR_BITS'h100))) begin
        enableSCtrl <= (WData != `AXI_DATA_BITS'd0);
    end
end
always_ff @(posedge clk) begin
    if (rst) begin
        clearSCtrl <= 1'b0;
    end
    else if (WValid && 
             ((cStateSCtrlW == Slave_IdleW && AWAddr == `AXI_ADDR_BITS'h200) ||
              (cStateSCtrlW == Slave_WReady && AWAddr_reg == `AXI_ADDR_BITS'h200))) begin
        clearSCtrl <= (WData != `AXI_DATA_BITS'd0);
    end
end

endmodule