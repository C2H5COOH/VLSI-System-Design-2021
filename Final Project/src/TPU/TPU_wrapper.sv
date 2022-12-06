`include "AXI_def.svh"
`include "TPU_def.svh"
`include "TPU.sv"
module TPU_wrapper(
    input               clk,
    input               rst,

    //READ ADDRESS
    input [`AXI_IDS_BITS-1:0]           ARId,
    input [`AXI_ADDR_BITS-1:0]          ARAddr,
    input [`AXI_LEN_BITS-1:0]           ARLen,
    input [`AXI_SIZE_BITS-1:0]          ARSize,
    input [1:0]                         ARBurst,
    input                               ARValid,
    output logic                        ARReady,
    //READ DATA
    output logic [`AXI_IDS_BITS-1:0]    RId,
    output logic [`AXI_DATA_BITS-1:0]   RData,
    output logic [1:0]                  RResp,
    output logic                        RLast,
    output logic                        RValid,
    input                               RReady,
    //WRITE ADDRESS
    input [`AXI_IDS_BITS-1:0]           AWId,
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
    output logic [`AXI_IDS_BITS-1:0]    BId,
    output logic [1:0]                  BResp,
    output logic                        BValid,
    input                               BReady,

    //TPU Interrupt
    output logic                        TPUDone
);
/** AXI **/
logic [`AXI_LEN_BITS-1:0]   axiLen;
/* AXI at idle state */
logic                       isAXIIdleState,
/* AXI at read state */
                            isAXIReadState,
/* AXI at write state */
                            isAXIWriteState,
/* axiLen == 0? */
                            axiBurstLenEqZero,
/* TPU data being read successfully or ready to be writen */
                            // TPU_RW_Valid,
/* Can receive AXI read request? */
                            AXIToRead,
/* Has received from AXI? */
                            hasAXIReceived,
/* Is ordered to write bias, weight or input? */
                            isOrderedToWriteAXI,
/* Can receive AXI write request? */
                            AXIToWrite,
/* Has received from AXI? */
                            hasAXIWriten;
TPU_AXI_State               cAXIState, nAXIState;
logic [`AXI_ADDR_BITS-1:0]  axiAddr_reg;

/* Write TPU input control */
logic                           TPUWriteInputControlEn;
/* TPU input control */
logic [`TPU_INPUT_CTRL_BIT-1:0] TPUInputControlData;

/* Write TPU systolic/W/OFM control */
logic                           TPUWriteSysControlEn;
/* TPU systolic/W/OFM control */
logic [`TPU_SYS_CTRL_BIT-1:0]   TPUSysControlData;

/* Write TPU data */
logic [`AXI_STRB_BITS-1:0]      TPUWE;
/* TPU data in */
logic [`AXI_DATA_BITS-1:0]      TPUDataIn;
/* Read TPU data */
logic                           TPUOE;
/* TPU data out */
logic [`AXI_DATA_BITS-1:0]      TPUDataOut;
/* TPU read/write done */
logic                           TPURWDone;

/* Constant Signals */
assign RResp = `AXI_RESP_OKAY;
assign BResp = `AXI_RESP_OKAY;
/* AXI Logic */
assign isAXIIdleState = (cAXIState == AXI_IDLE);
assign isAXIReadState = (cAXIState == AXI_READ) || (cAXIState == AXI_R_PENDING);
assign isAXIWriteState = (cAXIState == AXI_WRITE);

assign AXIToRead = isAXIIdleState && !AWValid && ARValid;
assign hasAXIReceived = isAXIReadState && RReady && TPURWDone;

assign AXIToWrite = isAXIIdleState && AWValid;
assign hasAXIWriten = isAXIWriteState && WValid && TPURWDone;

always_ff @(posedge clk) begin
    if (rst) begin
        cAXIState <= AXI_IDLE;
    end
    else begin
        cAXIState <= nAXIState;
    end
end
always_comb begin
    unique case (cAXIState)
    AXI_IDLE: begin
        if (AWValid) begin
            nAXIState = AXI_WRITE;
        end
        else if (ARValid) begin
            nAXIState = AXI_READ;
        end
        else begin
            nAXIState = AXI_IDLE;
        end
    end
    AXI_READ: begin
        if (RValid && !RReady) begin
            nAXIState = AXI_R_PENDING;
        end
        else if (RLast && RReady) begin
            nAXIState = AXI_IDLE;
        end
        else begin
            nAXIState = AXI_READ;
        end
    end
    AXI_R_PENDING: begin
        if (RReady && !RLast) begin
            nAXIState = AXI_READ;
        end
        else if (RLast && RReady) begin
            nAXIState = AXI_IDLE;
        end
        else begin
            nAXIState = AXI_R_PENDING;
        end
    end
    AXI_WRITE: begin
        if (BReady) begin
            nAXIState = AXI_IDLE;
        end
        else begin
            nAXIState = AXI_WRITE;
        end
    end
    endcase
end

/* AXI Length/Addr reg */
always_ff @(posedge clk) begin
    if (rst) begin
        axiLen <= `AXI_LEN_BITS'd0;
        axiAddr_reg <= `AXI_ADDR_BITS'd0;
    end
    else if (isAXIIdleState) begin
        if (AWValid) begin
            axiLen <= AWLen;
            axiAddr_reg <= AWAddr;
        end
        else if (ARValid) begin
            axiLen <= ARLen;
            axiAddr_reg <= ARAddr;
        end
    end
    else if (hasAXIReceived || hasAXIWriten) begin
        axiLen <= axiLen - `AXI_LEN_BITS'd1;
    end
end
assign axiBurstLenEqZero = (axiLen == `AXI_LEN_BITS'd0);

/* AR Channel */
always_comb begin
    if (AXIToRead) begin
        ARReady = 1'b1;
    end
    else begin
        ARReady = 1'b0;
    end
end
/* R Channel */
always_ff @(posedge clk) begin
    if (rst) begin
        RId <= `AXI_IDS_BITS'd0;
    end
    else if (AXIToRead) begin
        RId <= ARId;
    end
end
always_comb begin
    if (RValid && axiBurstLenEqZero) begin
        RLast = 1'b1;
    end
    else begin
        RLast = 1'b0;
    end
end
always_comb begin
    if (isAXIReadState && TPURWDone) begin
        RValid = 1'b1;
    end
    else begin
        RValid = 1'b0;
    end
end

/* AW Channel */
always_comb begin
    if (AXIToWrite) begin
        AWReady = 1'b1;
    end
    else begin
        AWReady = 1'b0;
    end
end

/* W Channel */
always_comb begin
    if ((AXIToWrite || isAXIWriteState) && (TPURWDone || TPUWriteInputControlEn || TPUWriteSysControlEn)) begin
        WReady = 1'b1;
    end
    else begin
        WReady = 1'b0;
    end
end

/* B Channel */
always_ff @(posedge clk) begin
    if (rst) begin
        BId <= `AXI_IDS_BITS'd0;
    end
    else if (AXIToWrite) begin
        BId <= AWId;
    end
end
always_ff @(posedge clk) begin
    if (rst) begin
        BValid <= 1'b0;
    end
    else if (WLast) begin
        BValid <= 1'b1;
    end
    else if (BReady) begin
        BValid <= 1'b0;
    end
end

/* Address decode */
always_comb begin
    if (WValid) begin
        if (AXIToWrite) begin
            TPUWriteInputControlEn = (AWAddr == `TPU_INPUT_CTRL_OFFSET);
        end
        else if (isAXIWriteState) begin
            TPUWriteInputControlEn = (axiAddr_reg == `TPU_INPUT_CTRL_OFFSET);
        end
        else begin
            TPUWriteInputControlEn = 1'b0;
        end
    end
    else begin
        TPUWriteInputControlEn = 1'b0;
    end
end
assign TPUInputControlData = WData[`TPU_INPUT_CTRL_BIT-1:0];

always_comb begin
    if (WValid) begin
        if (AXIToWrite) begin
            TPUWriteSysControlEn = (AWAddr == `TPU_SYS_CTRL_OFFSET);
        end
        else if (isAXIWriteState) begin
            TPUWriteSysControlEn = (axiAddr_reg == `TPU_SYS_CTRL_OFFSET);
        end
        else begin
            TPUWriteSysControlEn = 1'b0;
        end
    end
    else begin
        TPUWriteSysControlEn = 1'b0;
    end
end
assign TPUSysControlData = WData[`TPU_SYS_CTRL_BIT+31:32];

always_comb begin
    if (WValid) begin
        if (AXIToWrite && AWAddr == `TPU_DATA_OFFSET) begin
            TPUWE = WStrb;
        end
        else if (isAXIWriteState && axiAddr_reg == `TPU_DATA_OFFSET) begin
            TPUWE = WStrb;
        end
        else begin
            TPUWE = 8'd0;
        end
    end
    else begin
        TPUWE = 8'd0;
    end
end
assign TPUDataIn = WData;

assign TPUOE = RReady;//(cAXIState == AXI_READ);
assign RData = TPUDataOut;

TPU TPU0 (
    .clk(clk),
    .rst(rst),

    .writeInputControlEn(TPUWriteInputControlEn),
    .nInputControl(TPUInputControlData),
    .writeSysControlEn(TPUWriteSysControlEn),
    .nSysControl(TPUSysControlData),
    .writeDataEn(TPUWE),
    .DI(TPUDataIn),
    .readDataEn(TPUOE),
    .DO(TPUDataOut),
    .readWriteDone(TPURWDone),
    .done(TPUDone)
);
endmodule