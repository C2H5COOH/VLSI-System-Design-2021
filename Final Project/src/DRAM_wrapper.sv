`include "MEM_def.svh"
`include "AXI_def.svh"

module DRAM_wrapper(
    input                               clk,
    input                               rst,

    //READ ADDRESS
    input [`AXI_IDS_BITS-1:0]           ARId,
    input [`AXI_ADDR_BITS-1:0]          ARAddr,
    input [`AXI_LEN_BITS-1:0]           ARLen,
    input [`AXI_SIZE_BITS-1:0]          ARSize,
    input [`AXI_BURST_BITS-1:0]         ARBurst,
    input                               ARValid,
    output logic                        ARReady,
    //READ DATA
    output logic [`AXI_IDS_BITS-1:0]    RId,
    output logic [`AXI_DATA_BITS-1:0]   RData,
    output logic [`AXI_RESP_BITS-1:0]   RResp,
    output logic                        RLast,
    output logic                        RValid,
    input                               RReady,
    //WRITE ADDRESS
    input [`AXI_IDS_BITS-1:0]           AWId,
    input [`AXI_ADDR_BITS-1:0]          AWAddr,
    input [`AXI_LEN_BITS-1:0]           AWLen,
    input [`AXI_SIZE_BITS-1:0]          AWSize,
    input [`AXI_BURST_BITS-1:0]         AWBurst,
    input                               AWValid,
    output logic                        AWReady,
    //WRITE DATA
    input [`AXI_DATA_BITS-1:0]          WData,
    input [`AXI_STRB_BITS-1:0]          WStrb,
    input                               WLast,
    input                               WValid,
    output logic                        WReady,
    //WRITE RESPONSE
    output logic [`AXI_IDS_BITS-1:0]    BId,
    output logic [`AXI_RESP_BITS-1:0]   BResp,
    output logic                        BValid,
    input                               BReady,
    //DRAM Pins
    input [`RAM_DATA_BITS-1:0]          readQ,
    input [1:0]                         dramValid,
    output logic                        CSn,
    output logic [`AXI_STRB_BITS-1:0]   WEn,
    output logic                        RASn,
    output logic                        CASn,
    output logic [`RAM_ADDR_BITS-1:0]   addrDRAM,
    output logic [`RAM_DATA_BITS-1:0]   writeD
);

typedef enum logic [2:0] {
    ACT,
    ACTIVATED,
    READ,
    WRITE,
    PRE,
    PRE_ACT_R_PEND,
    PRE_ACT_W_PEND
} DRAM_State;

logic[`RAM_DATA_BITS-1:0]   dataReg;
logic[10:0]                 currentRowReg, AWRow, ARRow;
logic[10-`AXI_LEN_BITS:0]   cColBase, nColBase, AWColBase, ARColBase;
logic[`AXI_LEN_BITS-1:0]    cBurstOffset, nBurstOffset, AWBurstOffset, ARBurstOffset;
DRAM_State                  cStateDRAM, nStateDRAM;
logic[3:0]                  cLatencyCounter, cLatencyCounterAdd1, nLatencyCounter;
logic[`AXI_LEN_BITS-1:0]    burstLen;
logic                       cLatencyCounterEqZero, burstLenEqZero, rowHitR, rowHitW, rowMiss, cLatencyEnoughPA, cLatencyEnoughCAS, cLatencyEnoughPreAndAct, cPageFaultOnBurst;
logic[`AXI_STRB_BITS-1:0]   WStrb_reg;


/* Constant Signals */
assign RResp = `AXI_RESP_OKAY;
assign BResp = `AXI_RESP_OKAY;
assign CSn = 1'b0;

/* State Machine */
always_ff @(posedge clk) begin
    if (rst) begin
        cStateDRAM <= ACT;
    end
    else begin
        cStateDRAM <= nStateDRAM;
    end
end
always_comb begin
    case (cStateDRAM) 
        ACT: begin
            if (cLatencyEnoughPA) begin
                if (rowHitR) begin
                    nStateDRAM = READ;
                end
                else if (rowHitW) begin
                    nStateDRAM = WRITE;
                end
                else begin
                    nStateDRAM = ACTIVATED;
                end
            end
            else begin
                nStateDRAM = ACT;
            end
        end
        ACTIVATED: begin
            if (rowHitR) begin
                nStateDRAM = READ;
            end
            else if (rowHitW) begin
                nStateDRAM = WRITE;
            end
            else if (rowMiss) begin
                nStateDRAM = PRE;
            end
            else begin
                nStateDRAM = cStateDRAM;
            end
        end
        READ: begin
            if (burstLenEqZero && RValid && RReady) begin
                nStateDRAM = ACTIVATED;
            end
            else if (cPageFaultOnBurst && cLatencyEnoughCAS) begin
                nStateDRAM = PRE_ACT_R_PEND;
            end
            else begin
                nStateDRAM = READ;
            end
        end
        PRE_ACT_R_PEND: begin
            if (cLatencyEnoughPreAndAct) begin
                nStateDRAM = READ;
            end
            else begin
                nStateDRAM = PRE_ACT_R_PEND;
            end
        end
        WRITE: begin
            if (burstLenEqZero && cLatencyEnoughPA && BReady) begin
                nStateDRAM = ACTIVATED;
            end
            else if (cPageFaultOnBurst && cLatencyEnoughCAS) begin
                nStateDRAM = PRE_ACT_W_PEND;
            end
            else begin
                nStateDRAM = WRITE;
            end
        end
        PRE_ACT_W_PEND: begin
            if (cLatencyEnoughPreAndAct) begin
                nStateDRAM = WRITE;
            end
            else begin
                nStateDRAM = PRE_ACT_W_PEND;
            end
        end
        PRE: begin
            if (cLatencyEnoughPA) begin
                nStateDRAM = ACT;
            end
            else begin
                nStateDRAM = PRE;
            end
        end
        default: begin
            nStateDRAM = ACT;
        end
    endcase
end

/* Counter */
always_ff @(posedge clk) begin
    if (rst) begin
        cLatencyCounter <= 4'd0;
    end
    else begin
        cLatencyCounter <= nLatencyCounter;
    end
end
always_comb begin
    case (cStateDRAM)
        ACT: begin
            if (cLatencyEnoughPA && (rowHitR || rowHitW)) begin
                nLatencyCounter = 4'd0;
            end
            else begin
                nLatencyCounter = cLatencyCounterAdd1;
            end
        end
        ACTIVATED: begin
            nLatencyCounter = 4'd0;
        end
        READ: begin
            if (cLatencyEnoughCAS) begin
                nLatencyCounter = 4'd0;
            end
            else if (RValid) begin
                if (!CASn) begin
                    nLatencyCounter = 4'd1;
                end
                else begin
                    nLatencyCounter = cLatencyCounter;
                end
            end
            else begin
                nLatencyCounter = cLatencyCounterAdd1;
            end
        end
        PRE_ACT_R_PEND: begin
            if (cLatencyEnoughPreAndAct) begin
                nLatencyCounter = 4'd0;
            end
            else begin
                nLatencyCounter = cLatencyCounterAdd1;
            end
        end
        WRITE: begin
            if ((cLatencyCounterEqZero && !WValid) || 
                (cLatencyEnoughCAS && (!burstLenEqZero || (burstLenEqZero && BReady)))) begin
                nLatencyCounter = 4'd0;
            end
            else if (!CASn) begin
                nLatencyCounter = 4'd1;
            end
            else if (cLatencyEnoughCAS && burstLenEqZero && !BReady) begin
                nLatencyCounter = cLatencyCounter;
            end
            else begin
                nLatencyCounter = cLatencyCounterAdd1;
            end
        end
        PRE_ACT_W_PEND: begin
            if (cLatencyEnoughPreAndAct) begin
                nLatencyCounter = 4'd0;
            end
            else begin
                nLatencyCounter = cLatencyCounterAdd1;
            end
        end
        PRE: begin
            if (cLatencyEnoughPA) begin
                nLatencyCounter = 4'd0;
            end
            else begin
                nLatencyCounter = cLatencyCounterAdd1;
            end
        end
        default: begin
            nLatencyCounter = 4'd0;
        end
    endcase
end
assign cLatencyCounterAdd1 = cLatencyCounter + 4'd1;
assign cLatencyCounterEqZero = (cLatencyCounter == 4'd0);
assign cLatencyEnoughPA = (cLatencyCounter == 4'd4);
assign cLatencyEnoughCAS = (cLatencyCounter == 4'd5);
assign cPageFaultOnBurst = &cColBase && &cBurstOffset && !burstLenEqZero;
assign cLatencyEnoughPreAndAct = (cLatencyCounter == 4'd9);

/* RAS */
assign ARRow = ARAddr[24:14];
assign AWRow = AWAddr[24:14];
assign rowHitR  = (ARRow == currentRowReg && ARValid);
assign rowHitW  = (AWRow == currentRowReg && AWValid);
assign rowMiss = (ARRow != currentRowReg && ARValid) || (AWRow != currentRowReg && AWValid);
always_comb begin
    if ((cStateDRAM == ACT || cStateDRAM == PRE) && cLatencyCounterEqZero) begin
        RASn = 1'b0;
    end
    else if ((cStateDRAM == PRE_ACT_R_PEND || cStateDRAM == PRE_ACT_W_PEND) && (cLatencyCounterEqZero || cLatencyEnoughCAS)) begin
        RASn = 1'b0;
    end
    else begin
        RASn = 1'b1;
    end
end
always_ff @(posedge clk) begin
    if (rst) begin
        currentRowReg <= 11'd0;
    end
    else if (cStateDRAM == PRE && cLatencyEnoughPA) begin
        // if (ARReady) begin
        if (ARValid) begin
            currentRowReg <= ARRow;
        end
        // else if (AWReady) begin
        else if (AWValid) begin
            currentRowReg <= AWRow;
        end
        else begin
            currentRowReg <= 11'd0;
        end
    end
    else if (cStateDRAM == PRE_ACT_R_PEND || cStateDRAM == PRE_ACT_W_PEND) begin
        if (cLatencyEnoughPA) begin
            currentRowReg <= currentRowReg + 11'd1;
        end
        else begin
            currentRowReg <= currentRowReg;
        end
    end
    else begin
        currentRowReg <= currentRowReg;
    end
end

/* CAS */
assign ARColBase = ARAddr[13:3+`AXI_LEN_BITS];
assign ARBurstOffset = ARAddr[2+`AXI_LEN_BITS:3];
assign AWColBase = AWAddr[13:3+`AXI_LEN_BITS];
assign AWBurstOffset = AWAddr[2+`AXI_LEN_BITS:3];
/* For RReady not asserted case */
always_ff @(posedge clk) begin
    if (rst) begin
        CASn <= 1'b1;
    end
    else if (ARReady || (WReady && CASn)) begin
        CASn <= 1'b0;
    end
    else if ((cStateDRAM == READ || (cStateDRAM == WRITE && WValid)) && cLatencyEnoughCAS && !burstLenEqZero && !cPageFaultOnBurst)begin
        CASn <= 1'b0;
    end
    else if (((cStateDRAM == PRE_ACT_R_PEND) || (cStateDRAM == PRE_ACT_W_PEND)) && cLatencyEnoughPreAndAct) begin
        CASn <= 1'b0;
    end
    else begin
        CASn <= 1'b1;
    end
end
always_comb begin
    if (rst) begin
        nColBase = 7'd0;
        nBurstOffset = `AXI_LEN_BITS'd0;
    end
    else if (ARValid) begin
        nColBase = ARColBase;
        nBurstOffset = ARBurstOffset;
    end
    else if (AWValid) begin
        nColBase = AWColBase;
        nBurstOffset = AWBurstOffset;
    end
    else if ((cLatencyEnoughCAS && !cPageFaultOnBurst) || (cLatencyEnoughPreAndAct && cPageFaultOnBurst)) begin               //Default INCR burst
        nColBase = (&cBurstOffset) ? cColBase + 7'd1 : cColBase;
        nBurstOffset = cBurstOffset + 4'd1;
    end
    else begin
        nColBase = cColBase;
        nBurstOffset = cBurstOffset;
    end
end
always_ff @(posedge clk) begin
    cColBase <= nColBase;
    cBurstOffset <= nBurstOffset;
end

/* ADDR */
always_comb begin
    if (cStateDRAM == READ || cStateDRAM == WRITE) begin
        addrDRAM = {cColBase, cBurstOffset};
    end
    else if (cStateDRAM == PRE || cStateDRAM == ACT || cStateDRAM == PRE_ACT_R_PEND || cStateDRAM == PRE_ACT_W_PEND) begin
        addrDRAM = currentRowReg;
    end
    else begin
        addrDRAM = 11'd0;
    end
end

/* WEn */
always_comb begin
    case (cStateDRAM)
        WRITE: begin
            if (!CASn) begin
                WEn = ~WStrb_reg;
            end
            else begin
                WEn = 8'hff;
            end
        end
        PRE: begin
            if (cLatencyCounterEqZero) begin
                WEn = 8'h0;
            end
            else begin
                WEn = 8'hff;
            end
        end
        PRE_ACT_R_PEND: begin
            if (cLatencyCounterEqZero) begin
                WEn = 8'h0;
            end
            else begin
                WEn = 8'hff;
            end
        end        
        PRE_ACT_W_PEND: begin
            if (cLatencyCounterEqZero) begin
                WEn = 8'h0;
            end
            else begin
                WEn = 8'hff;
            end
        end
        default: begin
            WEn = 8'hff;
        end
    endcase
end
always_ff @(posedge clk) begin
    if (rst) begin
        WStrb_reg <= `AXI_STRB_BITS'd0;
    end
    else if (WValid) begin
        WStrb_reg <= WStrb;
    end
end

/* Burst */
always_ff @(posedge clk) begin
    if (rst) begin
        burstLen <= `AXI_LEN_BITS'd0;
    end
    else if ((cStateDRAM == ACTIVATED || (cStateDRAM == ACT && cLatencyEnoughPA))
                && ARValid) begin
        burstLen <= ARLen;
    end
    else if ((cStateDRAM == ACTIVATED || (cStateDRAM == ACT && cLatencyEnoughPA))
                && AWValid) begin
        burstLen <= AWLen;
    end
    else if (!burstLenEqZero && ((RValid && RReady) || (cLatencyEnoughCAS && cStateDRAM == WRITE))) begin
        burstLen <= burstLen - `AXI_LEN_BITS'b1;
    end
    else begin
        burstLen <= burstLen;
    end
end
assign burstLenEqZero = (burstLen == `AXI_LEN_BITS'd0);

/* AR Channel */
// ARReady
always_comb begin
    if (((cStateDRAM == ACT && cLatencyEnoughPA) || cStateDRAM == ACTIVATED) && rowHitR) begin
        ARReady = ARValid;
    end
    else begin
        ARReady = 1'b0;
    end
end

/* R Channel */
always_ff @(posedge clk) begin
    if (ARValid & ARReady) begin
        RId <= ARId;
    end
end
always_ff @(posedge clk) begin
    if (rst) begin
        RLast <= 1'b0;
    end
    else if (cStateDRAM == READ && cLatencyEnoughCAS && burstLenEqZero) begin
        RLast <= 1'b1;
    end
    else if (RReady) begin
        RLast <= 1'b0;
    end
end
always_ff @(posedge clk) begin
    if (rst) begin
        RValid <= 1'b0;
    end
    else begin
        if (cStateDRAM == READ && cLatencyEnoughCAS && !(RValid && RReady)) begin 
            /* Set (RValid, RReady) -> RValid: [(0, 0), (0, 1), (1, 0)] -> 1 / (1, 1) -> 0 */
            RValid <= 1'b1;
        end
        else if (RReady) begin  /* Reset */
            RValid <= 1'b0;
        end
    end
end
always_ff @(posedge clk) begin
    if (rst) begin
        dataReg <= `RAM_DATA_BITS'd0;
    end
    else begin
        if (&dramValid) begin
            dataReg <= readQ;
        end
        else begin
            dataReg <= dataReg;
        end
    end
end
assign RData = /*(dramValid) ? readQ : */dataReg;
always_ff @(posedge clk) begin
    if (rst) begin
        writeD <= `RAM_DATA_BITS'd0;
    end
    else begin
        if (WReady) begin
            writeD <= WData;
        end
    end
end


/* AW Channel */
always_comb begin
    if (((cStateDRAM == ACT && cLatencyEnoughPA) || cStateDRAM == ACTIVATED) && rowHitW) begin
        AWReady = AWValid & !ARValid;
    end
    else begin
        AWReady = 1'b0;
    end
end

/* W Channel */
always_comb begin
    WReady = WValid && cStateDRAM == WRITE && cLatencyCounterEqZero;
end

/* B Channel */
always_ff @(posedge clk) begin
    if (AWValid & AWReady) begin
        BId <= AWId;
    end
end
always_comb begin
    if (cStateDRAM == WRITE && burstLenEqZero && cLatencyEnoughPA) begin
        BValid = 1'b1;
    end
    else begin
        BValid = 1'b0;
    end
end
endmodule

