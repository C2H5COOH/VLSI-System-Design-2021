`timescale 10ps/1ps
`include "SystolicArray.sv"
`include "TPU_def.svh"
`include "IFM_wrapper_short.sv"
`include "IFM_wrapper_mid.sv"
`include "IFM_wrapper.sv"
`include "OFM_wrapper.sv"
`include "Weight_wrapper.sv"

module TPU(
    input                           clk,
    input                           rst,
    
    /* Input control */
    input                           writeInputControlEn,
    input [`TPU_INPUT_CTRL_BIT-1:0] nInputControl,
    /* Systolic array control */
    input                           writeSysControlEn,
    input [`TPU_SYS_CTRL_BIT-1:0]   nSysControl,
    /* Data read/write */
    input [7:0]                     writeDataEn,
    input [63:0]                    DI,
    input                           readDataEn,
    output logic [63:0]             DO,
    output logic                    readWriteDone,
    /* Current command done */
    output logic                    done
);
/* Input Control Regsiter */
InputModeEnum                       inputMode, nInputMode;
logic                               inputSRAMId, nInputSRAMId;
logic [`INPUT_CTRL_DEPTH_BIT-1:0]   inputDepth, nInputDepth;
logic [`INPUT_CTRL_WIDTH_BIT-1:0]   inputWidth, nInputWidth;
logic [`INPUT_IFM_WIDTH_BIT-1:0]    inputIFMWidth, nInputIFMWidth, 
                                    inputIFMWidthBound;
logic [`INPUT_IFM_HEIGHT_BIT-1:0]   inputIFMHeight, nInputIFMHeight,
                                    inputIFMHeightBound;
logic                               inputPadUpper, nInputPadUpper,
                                    inputPadDown, nInputPadDown,
                                    inputPadLeft, nInputPadLeft,
                                    inputPadRight, nInputPadRight,
                                    isFillingSRAM, 
                                    isThisLineFinished,
                                    isThisLineEnqFinished, 
                                    isThisLineDeqFinished,
                                    isWritingInputSRAMConv,
                                    isNextSplitInputSRAM0,
                                    inputStride1, 
                                    inputStride2,
                                    inputQThreshold;

logic                               isInputIdle, inputDone;
/* Input Control offset */
logic [`INPUT_ENQ_OFFSET_BIT-1:0]   inputEnqOffset;
logic [`INPUT_DEQ_OFFSET_BIT-1:0]   inputDeqOffset, inputDeqOffsetAdd1, inputDeqOffsetMin1;
/* Row offset in IFM */
logic [`INPUT_ROW_OFFSET_BIT-1:0]   inputRowOffset, inputRowOffsetAdd1;
/* Row index in IFM input register */
logic [`INPUT_ROW_INDEX_BIT-1:0]    inputRowIndex, inputRowIndexAdd1, inputRowIndexMin1;
/* Row offset and input Offset */
logic                               inputLeftmostPixelPad, inputRightmostPixelPad, inputUpmostPixelPad, inputLowestPixelPad;

/* Interconnection for IFM */
logic [`IFM_SRAM_ADDR_BIT-1:0]      IFM0_Cnt,
                                    IFM1_Addr;
logic [`IFM_SRAM_ADDR_MID_BIT-1:0]  IFM0_Addr, IFM0_Split_Addr_7;
logic [`IFM_SRAM_ADDR_SHORT_BIT-1:0]IFM0_Split_Addr  [0:`NUM_Q_SPLIT-2];
logic [`Q_INDEX_BIT-1:0]        Q_Index[0:`NUM_Q_SPLIT-1];
logic [1:0]                     thresholdResult [0:`NUM_Q_SPLIT-1];
logic [`IFM0_INDEX_BIT-1:0]     IFM0_Index;
logic [`MAC_IN_BIT-1:0]         IFM_SRAMToSYS       [0:`SYS_HEIGHT-1];
logic [`IFM_PER_BYTE_BIT-1:0]   IFM0_DataOut        [0:`SYS_HEIGHT-1],
                                IFM0_Split_DataOut  [0:`NUM_Q_SPLIT-1][0:`SYS_HEIGHT-1],
                                IFM1_DataOut        [0:`SYS_HEIGHT-1],
                                IFM0_DataIn         [0:`SYS_HEIGHT-1],
                                IFM1_DataIn         [0:`SYS_HEIGHT-1],
                                IFM_ConvInput       [0:`SYS_HEIGHT-1];
logic [`SYS_HEIGHT-1:0]         IFM0_WEB[0:`NUM_Q_SPLIT-1],
                                IFM1_WEB;

/* Interconneciton for weight */
logic [`W_SRAM_ADDR_BIT-1:0]    W_Addr, sysKernelToDepth;
logic [`IFM_PER_BYTE_BIT-1:0]   W_SRAMToSYS         [0:`SYS_WIDTH-1],
                                W_DataIn            [0:`SYS_WIDTH-1],
                                W_DataOut           [0:`SYS_WIDTH-1];
logic [`SYS_WIDTH-1:0]          W_WEB;

/* Interconnection for OFM */
logic [`OFM_SRAM_ADDR_BIT-1:0]  OFM_Addr, nOFM_Addr;
logic [`MAC_OUT_BIT-1:0]        OFM_SYSToACC        [0:`SYS_WIDTH-1],
                                OFM_SRAMOutput      [0:`SYS_WIDTH*2-1],
                                OFM_ACCToSRAM       [0:`SYS_WIDTH*2-1],
                                OFM_PartialFromSRAM [0:`SYS_WIDTH*2-1],
                                OFM_PartialFromSYS  [0:`SYS_WIDTH*2-1];
logic                           OFM_ACCOverflow     [0:`SYS_WIDTH*2-1];
logic [`SYS_WIDTH-1:0]          OFM0_WEB, OFM1_WEB;

/* Input Shimming Registers */
logic [`IFM_PER_BYTE_BIT-1:0]   IFM0_Shim1,
                                IFM1_Shim1,
                                IFM0_Shim2[0:1],
                                IFM1_Shim2[0:1],
                                IFM0_Shim3[0:2],
                                IFM1_Shim3[0:2],
                                IFM0_Shim4[0:3],
                                IFM1_Shim4[0:3],
                                IFM0_Shim5[0:4],
                                IFM1_Shim5[0:4],
                                IFM0_Shim6[0:5],
                                IFM1_Shim6[0:5],
                                IFM0_Shim7[0:6],
                                IFM1_Shim7[0:6],
                                IFM0_Shim8[0:7],
                                IFM1_Shim8[0:7];
/* Input Temporary Registers */
logic [`IFM_PER_BYTE_BIT-1:0]   IFM_InputReg[0:`NUM_INPUT_REG_ROW-1][0:`NUM_INPUT_REG_PER_ROW-1];

/* Output Shimming Registers */
logic [`MAC_OUT_BIT-1:0]OFM_Shim0[0:6],
                        OFM_Shim1[0:5],
                        OFM_Shim2[0:4],
                        OFM_Shim3[0:3],
                        OFM_Shim4[0:2],
                        OFM_Shim5[0:1],
                        OFM_Shim6;
/* Output Temporary Registers */
logic [`MAC_OUT_BIT-1:0]OFM_TmpReg[0:`SYS_WIDTH-1];
/* Bias Registers */
logic [`MAC_OUT_BIT-1:0]        Bias[0:`SYS_WIDTH-1];
/* Zero Point Register */
logic [`IFM_PER_BYTE_BIT-1:0]   IFM_ZeroPoint;
/* Quantize State Register */
Q_STATE qState;

/* Systolic array control register */
CommandEnum                         Command, nCommand;
SysWidthEnum                        sysWidth, nSysWidth;
logic [`SYS_CTRL_DEPTH_BIT-1:0]     sysDepth, nSysDepth;
logic [`SYS_CTRL_KERNEL_BIT-1:0]    sysKernel, nSysKernel;
logic [`SYS_WIDTH-1:0]              sysWeightOFMCtrl;
/* Systolic array counter to track how many steps have been processed */
logic [`SYS_COUNTER_BIT-1:0]        sysCounter, nSysCounter;
/* Is current command IDLE */
logic                               isIdle,
/* Is currently loading weight ? */
                                    isLoadingWeight,
/* Has weight been loaded ? */
                                    doneLoadingWeight,
/* Is currently ordered to consume ? */ 
                                    isOrderedToConsume,
/* Is currently ordered to write weight ? */ 
                                    isOrderedToWriteW, 
/* Is currently ordered to write bias ? */ 
                                    isOrderedToWriteBias,
                                    isWritingZeroPoint,
                                    isWritingBiasDone,
/* Is writing weight */
                                    isWritingWeight,
/* Is write data pending */
                                    isWriteDataPending,
                                    isSysReadWrite,
/* Is accumulating from OFM_SRAM ? */
                                    isACC,
                                    OFM_OE,
/* Which IFM SRAM to be consumed ? */
                                    consumeIFMId,
/* Is consuming one of IFM SRAM ? */
                                    isConsuming,
/* Is producing partial sum ? */
                                    isProducing,
/* Is currently ordered to read OFM ? */ 
                                    isOrderedToReadOFM,
/* If OFM reading is through quantization ? */
                                    throughQuant,
                                    softReset,
                                    sysDone;
/* Is OFM read in column or row major */
ROW_OR_COL                          rowOrCol;

/* Memory mapping decoded as read thorugh activation */
logic                               isWritingIFM0,
                                    isWritingIFM1;

integer                             shimIdx, weightMuxIdx, accIdx, weightInputIdx, biasIdx, inputPerRowIdx, inputRowIdx;

/** Address and control **/
/* Input control */
always_ff @(posedge clk) begin
    if (rst) begin
        inputMode <= INPUT_MODE_IDLE;
        inputSRAMId <= 1'b0;
        inputDepth <= `INPUT_CTRL_DEPTH_BIT'd0;
        inputWidth <= `INPUT_CTRL_WIDTH_BIT'd0;
        inputIFMWidth <= `INPUT_IFM_WIDTH_BIT'd0;
        inputIFMHeight <= `INPUT_IFM_HEIGHT_BIT'd0;
        inputPadUpper <= 1'b0;
        inputPadDown <= 1'b0;
        inputPadLeft <= 1'b0;
        inputPadRight <= 1'b0;
    end
    else begin
        inputMode <= (softReset) ? INPUT_MODE_IDLE : nInputMode;
        inputSRAMId <= nInputSRAMId;
        inputDepth <= nInputDepth;
        inputWidth <= nInputWidth;
        inputIFMWidth <= nInputIFMWidth;
        inputIFMHeight <= nInputIFMHeight;
        inputPadUpper <= nInputPadUpper;
        inputPadDown <= nInputPadDown;
        inputPadLeft <= nInputPadLeft;
        inputPadRight <= nInputPadRight;
    end
end

always_comb begin
    if (isConsuming && consumeIFMId == 1'b0) begin
        isNextSplitInputSRAM0 = (IFM0_Addr == `IFM_SRAM_ADDR_MID_BIT'd0) && (IFM0_Cnt != `IFM_SRAM_ADDR_BIT'd0) && ~&IFM0_Index;
    end
    else begin
        isNextSplitInputSRAM0 = (IFM0_Addr == `IFM_SRAM_ADDR_MID_BIT'd95) && ~&IFM0_Index;
    end
end
assign isInputIdle = (inputMode == INPUT_MODE_IDLE);
assign inputStride1 = (inputMode == INPUT_MODE_CONV2D_S1);
assign inputStride2 = (inputMode == INPUT_MODE_CONV2D_S2);
assign inputQThreshold = (inputMode == INPUT_Q_THRES);
/* Next input control */
always_comb begin
    if (writeInputControlEn) begin
        nInputMode = InputModeEnum'(nInputControl[2:0]);
        nInputSRAMId = nInputControl[3];
        nInputDepth = nInputControl[13:4];
        nInputWidth = nInputControl[17:14];
        nInputIFMWidth = nInputControl[9:4];
        nInputIFMHeight = nInputControl[15:10];
        nInputPadRight = nInputControl[16];
        nInputPadLeft = nInputControl[17];
        nInputPadDown = nInputControl[18];
        nInputPadUpper = nInputControl[19];
    end
    else begin
        nInputMode = inputMode;
        nInputSRAMId = inputSRAMId;
        nInputDepth = inputDepth;
        nInputWidth = inputWidth;
        nInputIFMWidth = inputIFMWidth;
        nInputIFMHeight = inputIFMHeight;
        nInputPadRight = inputPadRight;
        nInputPadLeft = inputPadLeft;
        nInputPadDown = inputPadDown;
        nInputPadUpper = inputPadUpper;
    end
end

assign inputIFMHeightBound = inputIFMHeight - `INPUT_IFM_HEIGHT_BIT'd1;
assign inputIFMWidthBound = inputIFMWidth - `INPUT_IFM_HEIGHT_BIT'd1;
assign isThisLineEnqFinished = (inputEnqOffset > inputIFMWidthBound[5:3]);
assign isThisLineDeqFinished = ((inputDeqOffsetAdd1 == inputIFMWidthBound) && !inputPadRight) ||
                            inputRightmostPixelPad;
assign isThisLineFinished = isThisLineEnqFinished && (!isFillingSRAM || isThisLineDeqFinished);
assign isWritingInputSRAMConv = isFillingSRAM && {inputEnqOffset, 3'd0} > inputDeqOffsetAdd1;

/* Is filling SRAM */
always_ff @(posedge clk) begin
    if (rst || softReset) begin
        isFillingSRAM <= 1'b0;
    end
    /* Stride 1 */
    else if (inputStride1 && inputRowIndex > inputRowOffset) begin
        isFillingSRAM <= 1'b1;
    end
    /* Stride 2 */
    else if (inputStride2) begin
        if (inputRowOffset == `INPUT_ROW_OFFSET_BIT'd1 && inputRowIndex == `INPUT_ROW_INDEX_BIT'd0) begin
            isFillingSRAM <= 1'b0;
        end
        else if (isThisLineFinished) begin
            isFillingSRAM <= ~isFillingSRAM;
        end
    end
end

/* Enqueue offset */
always_ff @(posedge clk) begin
    if (rst || softReset) begin
        inputEnqOffset <= `INPUT_ENQ_OFFSET_BIT'd0;
    end
    // Get command
    else if (isInputIdle && (nInputMode == INPUT_MODE_CONV2D_S1 || nInputMode == INPUT_MODE_CONV2D_S2)) begin
        inputEnqOffset <= `INPUT_ENQ_OFFSET_BIT'd0;
    end
    // Next input
    else if (isWriteDataPending && !isThisLineEnqFinished) begin
        inputEnqOffset <= inputEnqOffset + `INPUT_ENQ_OFFSET_BIT'd1;
    end
    // Next line
    else if (!done && isThisLineFinished) begin
        inputEnqOffset <= `INPUT_ENQ_OFFSET_BIT'd0;
    end
end

/* Dequeue offset */
always_ff @(posedge clk) begin
    if (rst || softReset) begin
        inputDeqOffset <= `INPUT_DEQ_OFFSET_BIT'd1;
    end
    // Get command or Nextline
    else if ((isInputIdle && (inputStride1 || inputStride2)) || isThisLineFinished) begin
        inputDeqOffset <= (nInputPadLeft) ? `INPUT_DEQ_OFFSET_BIT'd0 : `INPUT_DEQ_OFFSET_BIT'd1;
    end
    // Next Window
    else if (!done && isWritingInputSRAMConv) begin
        inputDeqOffset <= inputDeqOffset + ((inputMode == INPUT_MODE_CONV2D_S1) ? `INPUT_DEQ_OFFSET_BIT'd1 : `INPUT_DEQ_OFFSET_BIT'd2);
    end
    // Right bound
    else if ((inputDeqOffsetAdd1 == inputIFMWidthBound) && inputPadRight) begin
        inputDeqOffset <= inputIFMWidthBound;
    end
end

/* Row offset */
always_ff @(posedge clk) begin
    if (rst || softReset) begin
        inputRowOffset <= `INPUT_ROW_OFFSET_BIT'd0;
    end
    // Get command 
    else if (isInputIdle && nInputMode != INPUT_MODE_IDLE) begin
        inputRowOffset <= (nInputPadUpper) ? `INPUT_ROW_OFFSET_BIT'd0 : `INPUT_ROW_OFFSET_BIT'd1;
    end
    // Nextline
    else if (!done && isFillingSRAM && isThisLineFinished) begin
        inputRowOffset <= inputRowOffset + ((inputMode == INPUT_MODE_CONV2D_S1) ? `INPUT_DEQ_OFFSET_BIT'd1 : `INPUT_DEQ_OFFSET_BIT'd2);
    end
    // Pad lowest
    else if ((inputRowOffsetAdd1 == inputIFMHeightBound) && inputPadDown) begin
        inputRowOffset <= inputIFMHeightBound;
    end
end

/* Row index */
always_ff @(posedge clk) begin
    if (rst || softReset) begin
        inputRowIndex <= `INPUT_ROW_INDEX_BIT'd0;
    end
    else if (inputQThreshold) begin
        inputRowIndex <= (isWriteDataPending) ? inputRowIndexAdd1 : inputRowIndex;
    end
    else if(isThisLineFinished) begin
        inputRowIndex <= inputRowIndexAdd1;
    end
    else begin
        inputRowIndex <= inputRowIndex;
    end
end

/* Overall done */
always_comb begin
    unique case({isIdle, isInputIdle})
    2'b00: begin
        done = sysDone && inputDone;
    end
    2'b01: begin
        done = sysDone;
    end
    2'b10: begin
        done = inputDone;
    end
    default: begin
        done = 1'b0;
    end
    endcase
end

/* Input done */
always_ff @(posedge clk) begin
    if (rst || softReset) begin
        inputDone <= 1'b0;
    end
    /* Input without convolution */
    else if (inputMode == INPUT_MODE_NO_CONV) begin
        if ((inputSRAMId == 1'b0) && (IFM0_Cnt == inputDepth)) begin
            inputDone <= 1'b1;
        end
        else if ((inputSRAMId == 1'b1) && (IFM1_Addr == inputDepth)) begin
            inputDone <= 1'b1;
        end
        else begin
            inputDone <= 1'b0;
        end
    end
    /* Input with convolution */
    else if (inputStride1 || inputStride2) begin
        if (((((inputRowOffsetAdd1 == inputIFMHeightBound) && !inputPadDown) || inputLowestPixelPad) && isThisLineFinished) && isWritingInputSRAMConv) begin
            inputDone <= 1'b1;
        end
    end
    /* Input quantize threshold */
    else if (inputQThreshold) begin
        if (Q_Index[0] == 7'd84 && isWriteDataPending && ^inputRowIndex) begin
            inputDone <= 1'b1;
        end
    end
end

/* Input Offset */
// Leftmost
assign inputLeftmostPixelPad = (inputDeqOffset == `INPUT_DEQ_OFFSET_BIT'd0);
// Rightmost
assign inputRightmostPixelPad = (inputDeqOffset == inputIFMWidth);
// Uppermost
assign inputUpmostPixelPad = (inputRowOffset == `INPUT_ROW_OFFSET_BIT'd0);
// Lowest
assign inputLowestPixelPad = (inputRowOffset == inputIFMHeight);

assign inputDeqOffsetAdd1 = inputDeqOffset + `INPUT_DEQ_OFFSET_BIT'd1;
assign inputDeqOffsetMin1 = inputDeqOffset - `INPUT_DEQ_OFFSET_BIT'd1;
assign inputRowIndexAdd1 = (inputRowIndex == 2'd2) ? `INPUT_ROW_INDEX_BIT'd0 : (inputRowIndex + `INPUT_ROW_INDEX_BIT'd1);
assign inputRowIndexMin1 = (inputRowIndex == 2'd0) ? `INPUT_ROW_INDEX_BIT'd2 : (inputRowIndex - `INPUT_ROW_INDEX_BIT'd1);
assign inputRowOffsetAdd1 = inputRowOffset + `INPUT_ROW_OFFSET_BIT'd1;

/* Systoclic array control */
assign isIdle = (Command == IDLE);
assign softReset = (nCommand == IDLE) && writeSysControlEn;
/* Command register */
always @(posedge clk) begin
    if (rst || softReset) begin
        Command <= IDLE;
    end
    else begin
        Command <= nCommand;
    end
end
always_ff @(posedge clk) begin
    if (rst) begin
        sysWidth <= WIDTH_1;
    end
    else if (isIdle) begin
        sysWidth <= nSysWidth;
    end
end
always_ff @(posedge clk) begin
    if (rst) begin
        sysDepth <= `SYS_CTRL_DEPTH_BIT'd0;
    end
    else if (isIdle) begin
        sysDepth <= nSysDepth;
    end
end
always_ff @(posedge clk) begin
    if (rst) begin
        sysKernel <= `SYS_CTRL_KERNEL_BIT'd0;
    end
    else if (isIdle) begin
        sysKernel <= nSysKernel;
    end
end
always_comb begin
    sysKernelToDepth = (sysKernel << 3) + sysKernel + 8;
end
/* Next sys control */
always_comb begin
    if (writeSysControlEn) begin
        nSysWidth = SysWidthEnum'(nSysControl[24:22]);
        nSysDepth = {1'b0, nSysControl[21:12]};
        nSysKernel = nSysControl[11:5];
        nCommand = CommandEnum'(nSysControl[4:0]);
    end
    else begin
        nSysWidth = sysWidth;
        nSysDepth = sysDepth;
        nSysKernel = sysKernel;
        nCommand = (isWritingBiasDone) ? IDLE : Command;
    end
end
always_ff @(posedge clk) begin
    if (rst || softReset) begin
        sysDone <= 1'b0;
    end
    /* Input consuming */
    else if (isOrderedToConsume && (sysCounter > sysDepth + `SYS_FIRST_ARRIVE + 1)) begin
        sysDone <= 1'b1;
    end
    /* Weight writing */
    else if (isOrderedToWriteW && (sysCounter > sysKernelToDepth)) begin
        sysDone <= 1'b1;
    end
    /* Output reading */
    else if (isOrderedToReadOFM) begin
        if (throughQuant) begin
            if (sysDepth == sysCounter) begin
                sysDone <= 1'b1;
            end
        end
        else begin
            if (sysDepth == {OFM_Addr, sysCounter[2]}) begin
                sysDone <= 1'b1;
            end
        end
    end
end
always_comb begin
    if (done) begin
        readWriteDone = 1'b0;
    end
    else if (isOrderedToWriteBias || isOrderedToWriteW || (inputMode == INPUT_MODE_NO_CONV) || (isOrderedToReadOFM && !throughQuant) || inputQThreshold) begin
        readWriteDone = 1'b1;
    end
    else if ((inputStride1 || inputStride2) && !isThisLineEnqFinished) begin
        readWriteDone = 1'b1;
    end
    else if (isOrderedToReadOFM && throughQuant && (qState == QOUTPUT || qState == SORT_4_D)) begin
        readWriteDone = 1'b1;
    end
    else begin
        readWriteDone = 1'b0;
    end
end
        
assign isOrderedToConsume = (IDLE < Command) && (Command < WRITE_BIAS);
assign isOrderedToWriteBias = (Command == WRITE_BIAS);
assign isOrderedToWriteW = (Command == WRITE_W);
assign isOrderedToReadOFM = (WRITE_W < Command);
assign throughQuant = (Command == READ_OFM_ROW_QED) || (Command == READ_OFM_COL_QED);
assign isSysReadWrite = isOrderedToWriteBias || isOrderedToWriteW || isOrderedToReadOFM;
assign rowOrCol = ROW_OR_COL'((Command == READ_OFM_COL_RAW) || (Command == READ_OFM_COL_QED));
assign isWriteDataPending = |writeDataEn;
assign isWritingZeroPoint = isOrderedToWriteBias && (sysCounter == {8'b0, sysWidth} + `SYS_COUNTER_BIT'd1);
assign isWritingBiasDone = isOrderedToWriteBias && (sysCounter == {8'b0, sysWidth} + `SYS_COUNTER_BIT'd2);
always_ff @(posedge clk) begin
    if (rst) begin
        sysCounter <= `SYS_COUNTER_BIT'd0;
    end
    else begin
        sysCounter <= nSysCounter;
    end
end
always_comb begin
    if ((isLoadingWeight && sysCounter == `SYS_COUNTER_BIT'd10) || sysDone || softReset || isWritingBiasDone) begin
        nSysCounter = `SYS_COUNTER_BIT'd0;
    end
    else if (isSysReadWrite) begin
        if (readWriteDone) begin
            if (isWriteDataPending || readDataEn) begin
                nSysCounter = sysCounter + `SYS_COUNTER_BIT'd1;
            end
            else begin
                nSysCounter = sysCounter;
            end
        end
        else begin
            nSysCounter = sysCounter;
        end
    end
    else if (!isIdle && !isSysReadWrite) begin
        nSysCounter = sysCounter + `SYS_COUNTER_BIT'd1;
    end
    else begin
        nSysCounter = sysCounter;
    end
end

/* OFM_W_Related */
always_comb begin
    unique case (sysWidth)
    `SYS_CTRL_WIDTH_BIT'd0:
        sysWeightOFMCtrl = `SYS_WIDTH'h01;
    `SYS_CTRL_WIDTH_BIT'd1:
        sysWeightOFMCtrl = `SYS_WIDTH'h03;
    `SYS_CTRL_WIDTH_BIT'd2:
        sysWeightOFMCtrl = `SYS_WIDTH'h07;
    `SYS_CTRL_WIDTH_BIT'd3:
        sysWeightOFMCtrl = `SYS_WIDTH'h0f;
    `SYS_CTRL_WIDTH_BIT'd4:
        sysWeightOFMCtrl = `SYS_WIDTH'h1f;
    `SYS_CTRL_WIDTH_BIT'd5:
        sysWeightOFMCtrl = `SYS_WIDTH'h3f;
    `SYS_CTRL_WIDTH_BIT'd6:
        sysWeightOFMCtrl = `SYS_WIDTH'h7f;
    `SYS_CTRL_WIDTH_BIT'd7:
        sysWeightOFMCtrl = `SYS_WIDTH'hff;
    endcase
end
/* Weight SRAM control */
assign isWritingWeight = isOrderedToWriteW && !done;
always_ff @(posedge clk) begin
    if (rst || isIdle) begin
        W_Addr <= `W_SRAM_ADDR_BIT'd0;
    end
    else if (isOrderedToConsume) begin
        if (!isLoadingWeight) begin
            W_Addr <= sysKernelToDepth;
        end
        else begin
            W_Addr <= W_Addr - `W_SRAM_ADDR_BIT'd1;
        end
    end
    else if (isWritingWeight && isWriteDataPending) begin
        W_Addr <= W_Addr + `W_SRAM_ADDR_BIT'd1;
    end
end
/* For first 9 cycles, weight loading would be performed */
always_ff @(posedge clk) begin
    if (rst || softReset) begin
        doneLoadingWeight <= 1'b0;
    end
    else if (isLoadingWeight && sysCounter == 11'd9) begin
        doneLoadingWeight <= 1'b1;
    end
end
always_ff @(posedge clk) begin
    if (rst) begin
        isLoadingWeight <= 1'b0;
    end
    else if (isOrderedToConsume & !doneLoadingWeight) begin
        isLoadingWeight <= 1'b1;
    end
    else begin
        isLoadingWeight <= 1'b0;
    end
end
always_comb begin
    if (isWritingWeight) begin
        W_WEB = ~sysWeightOFMCtrl;
    end
    else begin
        W_WEB = ~`SYS_WIDTH'h0;
    end
end

/* Input SRAM control */
always_ff @(posedge clk) begin
    if (rst || softReset) begin
        IFM0_Addr <= `IFM_SRAM_ADDR_MID_BIT'd0;
        IFM0_Cnt <= `IFM_SRAM_ADDR_BIT'd0;
        IFM0_Index <= `IFM0_INDEX_BIT'd0;
    end
    // Sys
    else if (!isIdle && consumeIFMId == 1'b0) begin
        if (!isConsuming) begin
            IFM0_Addr <= `IFM_SRAM_ADDR_MID_BIT'd0;
            IFM0_Cnt <= `IFM_SRAM_ADDR_BIT'd0;
            IFM0_Index <= `IFM0_INDEX_BIT'd0;
        end
        else begin
            IFM0_Index <= (isNextSplitInputSRAM0) ? IFM0_Index + `IFM0_INDEX_BIT'd1 : IFM0_Index; 
            IFM0_Addr <= (IFM0_Addr == `IFM_SRAM_ADDR_MID_BIT'h5f && ~&IFM0_Index) ? `IFM_SRAM_ADDR_MID_BIT'd0 : IFM0_Addr + `IFM_SRAM_ADDR_MID_BIT'd1;
            IFM0_Cnt <= IFM0_Cnt + `IFM_SRAM_ADDR_BIT'd1;
        end
    end
    // Input
    else if (inputSRAMId == 1'b0) begin
        if (isInputIdle) begin
            IFM0_Addr <= `IFM_SRAM_ADDR_MID_BIT'd0;
            IFM0_Cnt <= `IFM_SRAM_ADDR_BIT'd0;
            IFM0_Index <= `IFM0_INDEX_BIT'd0;
        end
        else if (inputStride1 || inputStride2) begin
            if (isWritingInputSRAMConv) begin
                IFM0_Index <= (isNextSplitInputSRAM0) ? IFM0_Index + `IFM0_INDEX_BIT'd1 : IFM0_Index; 
                IFM0_Addr <= (isNextSplitInputSRAM0) ? `IFM_SRAM_ADDR_MID_BIT'd0 : IFM0_Addr + `IFM_SRAM_ADDR_MID_BIT'd1;
                IFM0_Cnt <= IFM0_Cnt + `IFM_SRAM_ADDR_BIT'd1;
            end
            else begin
                IFM0_Index <= IFM0_Index;
                IFM0_Addr <= IFM0_Addr;
                IFM0_Cnt <= IFM0_Cnt;
            end
        end
        else if (isWriteDataPending) begin
            IFM0_Index <= (isNextSplitInputSRAM0) ? IFM0_Index + `IFM0_INDEX_BIT'd1 : IFM0_Index; 
            IFM0_Addr <= (isNextSplitInputSRAM0) ? `IFM_SRAM_ADDR_MID_BIT'd0 : IFM0_Addr + `IFM_SRAM_ADDR_MID_BIT'd1;;
            IFM0_Cnt <= IFM0_Cnt + `IFM_SRAM_ADDR_BIT'd1;
        end
    end
end

/* Quantizatino Related */
function logic [6:0] getNextQIndex(
    input Q_STATE currentQState,
    input logic [6:0] cQIndex,
    input logic [1:0] cmpResult
);
    logic [6:0] offset;
    unique case (currentQState)
    QIDLE: begin
        getNextQIndex = 7'd0;
    end
    INPUT_2: begin
        getNextQIndex = 7'd0;    
    end
    INPUT_4: begin
        getNextQIndex = 7'd0;
    end
    INPUT_6: begin
        getNextQIndex = 7'd0;    
    end
    INPUT_8: begin
        getNextQIndex = 7'd0;
    end
    SORT_1_D: begin
        unique case(cmpResult)
        2'b00: begin
            offset = 7'd1;
        end
        2'b01: begin
            offset = 7'd22;
        end
        2'b10: begin
            offset = 7'd43;
        end
        2'b11: begin
            offset = 7'd64;
        end
        endcase
        getNextQIndex = offset;
    end
    SORT_2_D: begin
        unique case(cmpResult)
        2'b00: begin
            offset = 7'd1;
        end
        2'b01: begin
            offset = 7'd6;
        end
        2'b10: begin
            offset = 7'd11;
        end
        2'b11: begin
            offset = 7'd16;
        end
        endcase
        getNextQIndex = cQIndex + offset;
    end
    SORT_3_D: begin
        unique case(cmpResult)
        2'b00: begin
            offset = 7'd1;
        end
        2'b01: begin
            offset = 7'd2;
        end
        2'b10: begin
            offset = 7'd3;
        end
        2'b11: begin
            offset = 7'd4;
        end
        endcase
        getNextQIndex = cQIndex + offset;    
    end
    SORT_4_D: begin
        getNextQIndex = 7'd0;
    end
    default: begin
        getNextQIndex = cQIndex;
    end
    endcase
endfunction

always_ff @(posedge clk) begin
    if (rst || softReset) begin
        Q_Index[0] <= `Q_INDEX_BIT'd0;
        Q_Index[1] <= `Q_INDEX_BIT'd0;
        Q_Index[2] <= `Q_INDEX_BIT'd0;
        Q_Index[3] <= `Q_INDEX_BIT'd0;
        Q_Index[4] <= `Q_INDEX_BIT'd0;
        Q_Index[5] <= `Q_INDEX_BIT'd0;
        Q_Index[6] <= `Q_INDEX_BIT'd0;
        Q_Index[7] <= `Q_INDEX_BIT'd0;
    end
    else if (inputQThreshold) begin
        Q_Index[0] <= (isWriteDataPending && ^inputRowIndex) ? Q_Index[0] + `Q_INDEX_BIT'd1 : Q_Index[0];
        Q_Index[1] <= (isWriteDataPending && ^inputRowIndex) ? Q_Index[1] + `Q_INDEX_BIT'd1 : Q_Index[1];
        Q_Index[2] <= (isWriteDataPending && ^inputRowIndex) ? Q_Index[2] + `Q_INDEX_BIT'd1 : Q_Index[2];
        Q_Index[3] <= (isWriteDataPending && ^inputRowIndex) ? Q_Index[3] + `Q_INDEX_BIT'd1 : Q_Index[3];
        Q_Index[4] <= (isWriteDataPending && ^inputRowIndex) ? Q_Index[4] + `Q_INDEX_BIT'd1 : Q_Index[4];
        Q_Index[5] <= (isWriteDataPending && ^inputRowIndex) ? Q_Index[5] + `Q_INDEX_BIT'd1 : Q_Index[5];
        Q_Index[6] <= (isWriteDataPending && ^inputRowIndex) ? Q_Index[6] + `Q_INDEX_BIT'd1 : Q_Index[6];
        Q_Index[7] <= (isWriteDataPending && ^inputRowIndex) ? Q_Index[7] + `Q_INDEX_BIT'd1 : Q_Index[7];
    end
    else if (isOrderedToReadOFM && throughQuant) begin
        Q_Index[0] <= getNextQIndex(
            qState,
            Q_Index[0],
            thresholdResult[0]
        );
        Q_Index[1] <= getNextQIndex(
            qState,
            Q_Index[1],
            thresholdResult[1]
        );
        Q_Index[2] <= getNextQIndex(
            qState,
            Q_Index[2],
            thresholdResult[2]
        );
        Q_Index[3] <= getNextQIndex(
            qState,
            Q_Index[3],
            thresholdResult[3]
        );
        Q_Index[4] <= getNextQIndex(
            qState,
            Q_Index[4],
            thresholdResult[4]
        );
        Q_Index[5] <= getNextQIndex(
            qState,
            Q_Index[5],
            thresholdResult[5]
        );
        Q_Index[6] <= getNextQIndex(
            qState,
            Q_Index[6],
            thresholdResult[6]
        );
        Q_Index[7] <= getNextQIndex(
            qState,
            Q_Index[7],
            thresholdResult[7]
        );
    end
end

function logic[1:0] getCmpResult(
    input logic [`MAC_OUT_BIT-1:0] thresholds_0, thresholds_1, thresholds_2,
    input logic [`MAC_OUT_BIT-1:0] toBeCompared
);
    priority if ($signed(toBeCompared) < $signed(thresholds_0)) begin
        getCmpResult = 2'b00;
    end
    else if ($signed(thresholds_0) <= $signed(toBeCompared) && $signed(toBeCompared) < $signed(thresholds_1)) begin
        getCmpResult = 2'b01;
    end
    else if ($signed(thresholds_1) <= $signed(toBeCompared) && $signed(toBeCompared) < $signed(thresholds_2)) begin
        getCmpResult = 2'b10;
    end
    else begin
        getCmpResult = 2'b11;
    end
endfunction

always_comb begin
    thresholdResult[0] = getCmpResult(
        {IFM0_Split_DataOut[0][2], IFM0_Split_DataOut[0][1], IFM0_Split_DataOut[0][0]},
        {IFM0_Split_DataOut[0][5], IFM0_Split_DataOut[0][4], IFM0_Split_DataOut[0][3]},
        {IFM0_Split_DataOut[0][8], IFM0_Split_DataOut[0][7], IFM0_Split_DataOut[0][6]},
        OFM_TmpReg[0]
    );
    thresholdResult[1] = getCmpResult(
        {IFM0_Split_DataOut[1][2], IFM0_Split_DataOut[1][1], IFM0_Split_DataOut[1][0]},
        {IFM0_Split_DataOut[1][5], IFM0_Split_DataOut[1][4], IFM0_Split_DataOut[1][3]},
        {IFM0_Split_DataOut[1][8], IFM0_Split_DataOut[1][7], IFM0_Split_DataOut[1][6]},
        OFM_TmpReg[1]
    );
    thresholdResult[2] = getCmpResult(
        {IFM0_Split_DataOut[2][2], IFM0_Split_DataOut[2][1], IFM0_Split_DataOut[2][0]},
        {IFM0_Split_DataOut[2][5], IFM0_Split_DataOut[2][4], IFM0_Split_DataOut[2][3]},
        {IFM0_Split_DataOut[2][8], IFM0_Split_DataOut[2][7], IFM0_Split_DataOut[2][6]},
        OFM_TmpReg[2]
    );
    thresholdResult[3] = getCmpResult(
        {IFM0_Split_DataOut[3][2], IFM0_Split_DataOut[3][1], IFM0_Split_DataOut[3][0]},
        {IFM0_Split_DataOut[3][5], IFM0_Split_DataOut[3][4], IFM0_Split_DataOut[3][3]},
        {IFM0_Split_DataOut[3][8], IFM0_Split_DataOut[3][7], IFM0_Split_DataOut[3][6]},
        OFM_TmpReg[3]
    );
    thresholdResult[4] = getCmpResult(
        {IFM0_Split_DataOut[4][2], IFM0_Split_DataOut[4][1], IFM0_Split_DataOut[4][0]},
        {IFM0_Split_DataOut[4][5], IFM0_Split_DataOut[4][4], IFM0_Split_DataOut[4][3]},
        {IFM0_Split_DataOut[4][8], IFM0_Split_DataOut[4][7], IFM0_Split_DataOut[4][6]},
        OFM_TmpReg[4]
    );
    thresholdResult[5] = getCmpResult(
        {IFM0_Split_DataOut[5][2], IFM0_Split_DataOut[5][1], IFM0_Split_DataOut[5][0]},
        {IFM0_Split_DataOut[5][5], IFM0_Split_DataOut[5][4], IFM0_Split_DataOut[5][3]},
        {IFM0_Split_DataOut[5][8], IFM0_Split_DataOut[5][7], IFM0_Split_DataOut[5][6]},
        OFM_TmpReg[5]
    );
    thresholdResult[6] = getCmpResult(
        {IFM0_Split_DataOut[6][2], IFM0_Split_DataOut[6][1], IFM0_Split_DataOut[6][0]},
        {IFM0_Split_DataOut[6][5], IFM0_Split_DataOut[6][4], IFM0_Split_DataOut[6][3]},
        {IFM0_Split_DataOut[6][8], IFM0_Split_DataOut[6][7], IFM0_Split_DataOut[6][6]},
        OFM_TmpReg[6]
    );
    thresholdResult[7] = getCmpResult(
        {IFM0_Split_DataOut[7][2], IFM0_Split_DataOut[7][1], IFM0_Split_DataOut[7][0]},
        {IFM0_Split_DataOut[7][5], IFM0_Split_DataOut[7][4], IFM0_Split_DataOut[7][3]},
        {IFM0_Split_DataOut[7][8], IFM0_Split_DataOut[7][7], IFM0_Split_DataOut[7][6]},
        OFM_TmpReg[7]
    );
end

always_ff @(posedge clk) begin
    if (rst || softReset) begin
        qState <= QIDLE;
    end
    else begin
        unique case (qState) 
        QIDLE: begin
            if (throughQuant) begin
                qState <= (rowOrCol == COL) ? INPUT_2 : INPUT_8;
            end
            else begin
                qState <= QIDLE;
            end
        end
        INPUT_2: begin
            qState <= INPUT_4;
        end
        INPUT_4: begin
            qState <= INPUT_6;
        end
        INPUT_6: begin
            qState <= INPUT_8;
        end
        INPUT_8: begin
            qState <= SORT_1_D;
        end
        SORT_1_D: begin
            qState <= SORT_2_A;
        end
        SORT_2_A: begin
            qState <= SORT_2_D;
        end
        SORT_2_D: begin
            qState <= SORT_3_A;
        end
        SORT_3_A: begin
            qState <= SORT_3_D;
        end
        SORT_3_D: begin
            qState <= SORT_4_A;
        end
        SORT_4_A: begin
            qState <= SORT_4_D;
        end
        SORT_4_D: begin
            if (readDataEn) begin
                qState <= (rowOrCol == COL) ? INPUT_2 : INPUT_8;
            end
            else begin
                qState <= QOUTPUT;
            end
        end
        QOUTPUT: begin
            if (readDataEn) begin
                qState <= (rowOrCol == COL) ? INPUT_2 : INPUT_8;
            end
            else begin
                qState <= QOUTPUT;
            end
        end
        default: begin
            qState <= QIDLE;
        end
        endcase
    end
end

always_comb begin
    if (inputQThreshold || throughQuant) begin
        IFM0_Split_Addr[0] = Q_Index[0];
        IFM0_Split_Addr[1] = Q_Index[1];
        IFM0_Split_Addr[2] = Q_Index[2];
        IFM0_Split_Addr[3] = Q_Index[3];
        IFM0_Split_Addr[4] = Q_Index[4];
        IFM0_Split_Addr[5] = Q_Index[5];
        IFM0_Split_Addr[6] = Q_Index[6];
        IFM0_Split_Addr_7 = {1'b0, Q_Index[7]};
    end
    else begin
        IFM0_Split_Addr[0] = IFM0_Addr[`IFM_SRAM_ADDR_SHORT_BIT-1:0];
        IFM0_Split_Addr[1] = IFM0_Addr[`IFM_SRAM_ADDR_SHORT_BIT-1:0];
        IFM0_Split_Addr[2] = IFM0_Addr[`IFM_SRAM_ADDR_SHORT_BIT-1:0];
        IFM0_Split_Addr[3] = IFM0_Addr[`IFM_SRAM_ADDR_SHORT_BIT-1:0];
        IFM0_Split_Addr[4] = IFM0_Addr[`IFM_SRAM_ADDR_SHORT_BIT-1:0];
        IFM0_Split_Addr[5] = IFM0_Addr[`IFM_SRAM_ADDR_SHORT_BIT-1:0];
        IFM0_Split_Addr[6] = IFM0_Addr[`IFM_SRAM_ADDR_SHORT_BIT-1:0];
        IFM0_Split_Addr_7 = IFM0_Addr;
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        IFM1_Addr <= `IFM_SRAM_ADDR_BIT'd0;
    end
    // Sys
    else if (!isIdle && consumeIFMId == 1'b1) begin
        if (!isConsuming) begin
            IFM1_Addr <= `IFM_SRAM_ADDR_BIT'd0;
        end
        else begin
            IFM1_Addr <= IFM1_Addr + `IFM_SRAM_ADDR_BIT'd1;
        end
    end
    // Input
    else if (inputSRAMId == 1'b1) begin
        if (isInputIdle) begin
            IFM1_Addr <= `IFM_SRAM_ADDR_BIT'd0;
        end
        else if (inputStride1 || inputStride2) begin
            IFM1_Addr <= (isWritingInputSRAMConv) ? IFM1_Addr + `IFM_SRAM_ADDR_BIT'd1 : IFM1_Addr;
        end
        else if (isWriteDataPending) begin
            IFM1_Addr <= IFM1_Addr + `IFM_SRAM_ADDR_BIT'd1;
        end
    end
end
always_comb begin
    if (Command == CONSUME_IFM_SRAM1_BIAS || Command == CONSUME_IFM_SRAM1_ACC) begin
        consumeIFMId = 1'b1;
    end
    else begin
        consumeIFMId = 1'b0;
    end
end
assign isConsuming = isOrderedToConsume && !isLoadingWeight && (sysCounter <= sysDepth) && !sysDone;

/* Output SRAM control */
assign isProducing = isOrderedToConsume && !isLoadingWeight && (sysCounter > `SYS_FIRST_ARRIVE) && (sysCounter[0]) && !sysDone;
always_ff @(posedge clk) begin
    if (rst) begin
        OFM_Addr <= `OFM_SRAM_ADDR_BIT'd0;
    end
    else begin
        OFM_Addr <= nOFM_Addr;
    end
end
always_comb begin
    if (isIdle) begin
        nOFM_Addr = `OFM_SRAM_ADDR_BIT'd0;
    end
    else if (isProducing) begin
        nOFM_Addr = OFM_Addr + `OFM_SRAM_ADDR_BIT'd1;
    end
    else if (isOrderedToReadOFM) begin
        unique if (throughQuant) begin
            unique if (rowOrCol == COL) begin
                nOFM_Addr = ((qState < INPUT_8) || (readWriteDone && readDataEn)) ? OFM_Addr + `OFM_SRAM_ADDR_BIT'd1 : OFM_Addr;
            end
            else begin
                nOFM_Addr = (sysCounter[0] && (qState == SORT_3_D)) ? OFM_Addr + `OFM_SRAM_ADDR_BIT'd1 : OFM_Addr;
            end
        end
        else begin
            nOFM_Addr = (readDataEn && &sysCounter[2:0]) ? OFM_Addr + `OFM_SRAM_ADDR_BIT'd1 : OFM_Addr;
        end
    end
    else begin
        nOFM_Addr = OFM_Addr;
    end
end
always_comb begin
    if (Command == CONSUME_IFM_SRAM0_ACC || Command == CONSUME_IFM_SRAM1_ACC) begin
        isACC = 1'b1;
    end
    else begin
        isACC = 1'b0;
    end
end
always_comb begin
    if (isProducing) begin
        OFM0_WEB = ~sysWeightOFMCtrl;
        OFM1_WEB = ~sysWeightOFMCtrl;
    end
    else begin
        OFM0_WEB = `SYS_WIDTH'hff;
        OFM1_WEB = `SYS_WIDTH'hff;
    end
end
always_comb begin
    OFM_OE = isACC || isOrderedToReadOFM;
end

/** Data **/
/* Connection from IFM_SRAMs to systolic array */
always_ff @(posedge clk) begin
    if (consumeIFMId) begin
        IFM_SRAMToSYS[0] <= {1'b0, IFM1_DataOut[0]} - {1'b0, IFM_ZeroPoint};
        IFM_SRAMToSYS[1] <= {1'b0, IFM1_Shim1} - {1'b0, IFM_ZeroPoint};
        IFM_SRAMToSYS[2] <= {1'b0, IFM1_Shim2[1]} - {1'b0, IFM_ZeroPoint};
        IFM_SRAMToSYS[3] <= {1'b0, IFM1_Shim3[2]} - {1'b0, IFM_ZeroPoint};
        IFM_SRAMToSYS[4] <= {1'b0, IFM1_Shim4[3]} - {1'b0, IFM_ZeroPoint};
        IFM_SRAMToSYS[5] <= {1'b0, IFM1_Shim5[4]} - {1'b0, IFM_ZeroPoint};
        IFM_SRAMToSYS[6] <= {1'b0, IFM1_Shim6[5]} - {1'b0, IFM_ZeroPoint};
        IFM_SRAMToSYS[7] <= {1'b0, IFM1_Shim7[6]} - {1'b0, IFM_ZeroPoint};
        IFM_SRAMToSYS[8] <= {1'b0, IFM1_Shim8[7]} - {1'b0, IFM_ZeroPoint};
    end
    else begin
        IFM_SRAMToSYS[0] <= {1'b0, IFM0_DataOut[0]} - {1'b0, IFM_ZeroPoint};
        IFM_SRAMToSYS[1] <= {1'b0, IFM0_Shim1} - {1'b0, IFM_ZeroPoint};
        IFM_SRAMToSYS[2] <= {1'b0, IFM0_Shim2[1]} - {1'b0, IFM_ZeroPoint};
        IFM_SRAMToSYS[3] <= {1'b0, IFM0_Shim3[2]} - {1'b0, IFM_ZeroPoint};
        IFM_SRAMToSYS[4] <= {1'b0, IFM0_Shim4[3]} - {1'b0, IFM_ZeroPoint};
        IFM_SRAMToSYS[5] <= {1'b0, IFM0_Shim5[4]} - {1'b0, IFM_ZeroPoint};
        IFM_SRAMToSYS[6] <= {1'b0, IFM0_Shim6[5]} - {1'b0, IFM_ZeroPoint};
        IFM_SRAMToSYS[7] <= {1'b0, IFM0_Shim7[6]} - {1'b0, IFM_ZeroPoint};
        IFM_SRAMToSYS[8] <= {1'b0, IFM0_Shim8[7]} - {1'b0, IFM_ZeroPoint};
    end
end

always_comb begin
    unique case (IFM0_Index) 
    `IFM0_INDEX_BIT'd0: begin
        IFM0_DataOut[0] = IFM0_Split_DataOut[0][0];
        IFM0_DataOut[1] = IFM0_Split_DataOut[0][1];
        IFM0_DataOut[2] = IFM0_Split_DataOut[0][2];
        IFM0_DataOut[3] = IFM0_Split_DataOut[0][3];
        IFM0_DataOut[4] = IFM0_Split_DataOut[0][4];
        IFM0_DataOut[5] = IFM0_Split_DataOut[0][5];
        IFM0_DataOut[6] = IFM0_Split_DataOut[0][6];
        IFM0_DataOut[7] = IFM0_Split_DataOut[0][7];
        IFM0_DataOut[8] = IFM0_Split_DataOut[0][8];
    end
    `IFM0_INDEX_BIT'd1: begin
        IFM0_DataOut[0] = IFM0_Split_DataOut[1][0];
        IFM0_DataOut[1] = IFM0_Split_DataOut[1][1];
        IFM0_DataOut[2] = IFM0_Split_DataOut[1][2];
        IFM0_DataOut[3] = IFM0_Split_DataOut[1][3];
        IFM0_DataOut[4] = IFM0_Split_DataOut[1][4];
        IFM0_DataOut[5] = IFM0_Split_DataOut[1][5];
        IFM0_DataOut[6] = IFM0_Split_DataOut[1][6];
        IFM0_DataOut[7] = IFM0_Split_DataOut[1][7];
        IFM0_DataOut[8] = IFM0_Split_DataOut[1][8];
    end
    `IFM0_INDEX_BIT'd2: begin
        IFM0_DataOut[0] = IFM0_Split_DataOut[2][0];
        IFM0_DataOut[1] = IFM0_Split_DataOut[2][1];
        IFM0_DataOut[2] = IFM0_Split_DataOut[2][2];
        IFM0_DataOut[3] = IFM0_Split_DataOut[2][3];
        IFM0_DataOut[4] = IFM0_Split_DataOut[2][4];
        IFM0_DataOut[5] = IFM0_Split_DataOut[2][5];
        IFM0_DataOut[6] = IFM0_Split_DataOut[2][6];
        IFM0_DataOut[7] = IFM0_Split_DataOut[2][7];
        IFM0_DataOut[8] = IFM0_Split_DataOut[2][8];
    end
    `IFM0_INDEX_BIT'd3: begin
        IFM0_DataOut[0] = IFM0_Split_DataOut[3][0];
        IFM0_DataOut[1] = IFM0_Split_DataOut[3][1];
        IFM0_DataOut[2] = IFM0_Split_DataOut[3][2];
        IFM0_DataOut[3] = IFM0_Split_DataOut[3][3];
        IFM0_DataOut[4] = IFM0_Split_DataOut[3][4];
        IFM0_DataOut[5] = IFM0_Split_DataOut[3][5];
        IFM0_DataOut[6] = IFM0_Split_DataOut[3][6];
        IFM0_DataOut[7] = IFM0_Split_DataOut[3][7];
        IFM0_DataOut[8] = IFM0_Split_DataOut[3][8];
    end
    `IFM0_INDEX_BIT'd4: begin
        IFM0_DataOut[0] = IFM0_Split_DataOut[4][0];
        IFM0_DataOut[1] = IFM0_Split_DataOut[4][1];
        IFM0_DataOut[2] = IFM0_Split_DataOut[4][2];
        IFM0_DataOut[3] = IFM0_Split_DataOut[4][3];
        IFM0_DataOut[4] = IFM0_Split_DataOut[4][4];
        IFM0_DataOut[5] = IFM0_Split_DataOut[4][5];
        IFM0_DataOut[6] = IFM0_Split_DataOut[4][6];
        IFM0_DataOut[7] = IFM0_Split_DataOut[4][7];
        IFM0_DataOut[8] = IFM0_Split_DataOut[4][8];
    end
    `IFM0_INDEX_BIT'd5: begin
        IFM0_DataOut[0] = IFM0_Split_DataOut[5][0];
        IFM0_DataOut[1] = IFM0_Split_DataOut[5][1];
        IFM0_DataOut[2] = IFM0_Split_DataOut[5][2];
        IFM0_DataOut[3] = IFM0_Split_DataOut[5][3];
        IFM0_DataOut[4] = IFM0_Split_DataOut[5][4];
        IFM0_DataOut[5] = IFM0_Split_DataOut[5][5];
        IFM0_DataOut[6] = IFM0_Split_DataOut[5][6];
        IFM0_DataOut[7] = IFM0_Split_DataOut[5][7];
        IFM0_DataOut[8] = IFM0_Split_DataOut[5][8];
    end
    `IFM0_INDEX_BIT'd6: begin
        IFM0_DataOut[0] = IFM0_Split_DataOut[6][0];
        IFM0_DataOut[1] = IFM0_Split_DataOut[6][1];
        IFM0_DataOut[2] = IFM0_Split_DataOut[6][2];
        IFM0_DataOut[3] = IFM0_Split_DataOut[6][3];
        IFM0_DataOut[4] = IFM0_Split_DataOut[6][4];
        IFM0_DataOut[5] = IFM0_Split_DataOut[6][5];
        IFM0_DataOut[6] = IFM0_Split_DataOut[6][6];
        IFM0_DataOut[7] = IFM0_Split_DataOut[6][7];
        IFM0_DataOut[8] = IFM0_Split_DataOut[6][8];
    end
    `IFM0_INDEX_BIT'd7: begin
        IFM0_DataOut[0] = IFM0_Split_DataOut[7][0];
        IFM0_DataOut[1] = IFM0_Split_DataOut[7][1];
        IFM0_DataOut[2] = IFM0_Split_DataOut[7][2];
        IFM0_DataOut[3] = IFM0_Split_DataOut[7][3];
        IFM0_DataOut[4] = IFM0_Split_DataOut[7][4];
        IFM0_DataOut[5] = IFM0_Split_DataOut[7][5];
        IFM0_DataOut[6] = IFM0_Split_DataOut[7][6];
        IFM0_DataOut[7] = IFM0_Split_DataOut[7][7];
        IFM0_DataOut[8] = IFM0_Split_DataOut[7][8];
    end
    endcase
end

/* Connection from systolic array or external input to OFM/W temp registers */
always_ff @(posedge clk) begin
    if (isOrderedToReadOFM && throughQuant) begin
        if (rowOrCol == COL) begin
            unique case (qState) 
            QIDLE: begin
                OFM_TmpReg[0] <= OFM_SRAMOutput[0];
                OFM_TmpReg[1] <= OFM_SRAMOutput[8];
            end
            QOUTPUT: begin
                OFM_TmpReg[0] <= OFM_SRAMOutput[0];
                OFM_TmpReg[1] <= OFM_SRAMOutput[8];
            end
            SORT_4_D: begin
                OFM_TmpReg[0] <= OFM_SRAMOutput[0];
                OFM_TmpReg[1] <= OFM_SRAMOutput[8];
            end
            INPUT_2: begin
                OFM_TmpReg[2] <= OFM_SRAMOutput[0];
                OFM_TmpReg[3] <= OFM_SRAMOutput[8];
            end
            INPUT_4: begin
                OFM_TmpReg[4] <= OFM_SRAMOutput[0];
                OFM_TmpReg[5] <= OFM_SRAMOutput[8];
            end
            INPUT_6: begin
                OFM_TmpReg[6] <= OFM_SRAMOutput[0];
                OFM_TmpReg[7] <= OFM_SRAMOutput[8];
            end
            default: begin
            end
            endcase
        end
        else begin
            if (sysCounter[0] ^ (qState == SORT_4_D)) begin
                OFM_TmpReg[0] <= OFM_SRAMOutput[8];
                OFM_TmpReg[1] <= OFM_SRAMOutput[9];
                OFM_TmpReg[2] <= OFM_SRAMOutput[10];
                OFM_TmpReg[3] <= OFM_SRAMOutput[11];
                OFM_TmpReg[4] <= OFM_SRAMOutput[12];
                OFM_TmpReg[5] <= OFM_SRAMOutput[13];
                OFM_TmpReg[6] <= OFM_SRAMOutput[14];
                OFM_TmpReg[7] <= OFM_SRAMOutput[15];
            end
            else begin
                OFM_TmpReg[0] <= OFM_SRAMOutput[0];
                OFM_TmpReg[1] <= OFM_SRAMOutput[1];
                OFM_TmpReg[2] <= OFM_SRAMOutput[2];
                OFM_TmpReg[3] <= OFM_SRAMOutput[3];
                OFM_TmpReg[4] <= OFM_SRAMOutput[4];
                OFM_TmpReg[5] <= OFM_SRAMOutput[5];
                OFM_TmpReg[6] <= OFM_SRAMOutput[6];
                OFM_TmpReg[7] <= OFM_SRAMOutput[7];
            end
        end
    end
    else begin
        OFM_TmpReg[0] <= OFM_Shim0[6];
        OFM_TmpReg[1] <= OFM_Shim1[5];
        OFM_TmpReg[2] <= OFM_Shim2[4];
        OFM_TmpReg[3] <= OFM_Shim3[3];
        OFM_TmpReg[4] <= OFM_Shim4[2];
        OFM_TmpReg[5] <= OFM_Shim5[1];
        OFM_TmpReg[6] <= OFM_Shim6;
        OFM_TmpReg[7] <= OFM_SYSToACC[7];
    end
end

/* Connection from OFM/W temp registers to W SRAM */
always_comb begin
    W_DataIn[0] = DI[7:0];
    W_DataIn[1] = DI[15:8];
    W_DataIn[2] = DI[23:16];
    W_DataIn[3] = DI[31:24];
    W_DataIn[4] = DI[39:32];
    W_DataIn[5] = DI[47:40];
    W_DataIn[6] = DI[55:48];
    W_DataIn[7] = DI[63:56];
end
/* Connection from W_SRAM to systolic array */
always_comb begin
    for (weightMuxIdx = 0; weightMuxIdx < `SYS_WIDTH; weightMuxIdx += 1) begin
        if (sysWeightOFMCtrl[weightMuxIdx] && isLoadingWeight) begin
            W_SRAMToSYS[weightMuxIdx] = W_DataOut[weightMuxIdx];
        end
        else begin
            W_SRAMToSYS[weightMuxIdx] = `SYS_WIDTH'd0;
        end
    end
end

/* Connection from systolic array to OFM_SRAM */
always_comb begin
    OFM_PartialFromSYS[0] = OFM_TmpReg[0];
    OFM_PartialFromSYS[1] = OFM_TmpReg[1];
    OFM_PartialFromSYS[2] = OFM_TmpReg[2];
    OFM_PartialFromSYS[3] = OFM_TmpReg[3];
    OFM_PartialFromSYS[4] = OFM_TmpReg[4];
    OFM_PartialFromSYS[5] = OFM_TmpReg[5];
    OFM_PartialFromSYS[6] = OFM_TmpReg[6];
    OFM_PartialFromSYS[7] = OFM_TmpReg[7];
    OFM_PartialFromSYS[8] = OFM_Shim0[6];
    OFM_PartialFromSYS[9] = OFM_Shim1[5];
    OFM_PartialFromSYS[10] = OFM_Shim2[4];
    OFM_PartialFromSYS[11] = OFM_Shim3[3];
    OFM_PartialFromSYS[12] = OFM_Shim4[2];
    OFM_PartialFromSYS[13] = OFM_Shim5[1];
    OFM_PartialFromSYS[14] = OFM_Shim6;
    OFM_PartialFromSYS[15] = OFM_SYSToACC[7];
end
/* Currently only consider accumulater to SRAM, excluding external input to SRAM */
always_comb begin
    for (accIdx = 0; accIdx < (2*`SYS_WIDTH); accIdx += 1) begin
        OFM_PartialFromSRAM[accIdx] = (isACC) ? OFM_SRAMOutput[accIdx] : Bias[accIdx&7];
        {OFM_ACCOverflow[accIdx], OFM_ACCToSRAM[accIdx]} = 
            {OFM_PartialFromSRAM[accIdx][`MAC_OUT_BIT-1], OFM_PartialFromSRAM[accIdx]} + {OFM_PartialFromSYS[accIdx][`MAC_OUT_BIT-1], OFM_PartialFromSYS[accIdx]};
        unique case ({OFM_ACCOverflow[accIdx], OFM_ACCToSRAM[accIdx][`MAC_OUT_BIT-1]})
        2'b00: begin
            OFM_ACCToSRAM[accIdx] = OFM_ACCToSRAM[accIdx];
        end
        2'b11: begin
            OFM_ACCToSRAM[accIdx] = OFM_ACCToSRAM[accIdx];
        end
        2'b01: begin
            OFM_ACCToSRAM[accIdx] = `MAC_MAX;
        end
        2'b10: begin
            OFM_ACCToSRAM[accIdx] = `MAC_MIN;
        end
        default: begin
            OFM_ACCToSRAM[accIdx] = OFM_ACCToSRAM[accIdx];
        end
        endcase
    end
end

/* Connection among shimming registers */
always_ff @(posedge clk) begin
    IFM0_Shim1 <= IFM0_DataOut[1];
    IFM1_Shim1 <= IFM1_DataOut[1];
    IFM0_Shim2[0] <= IFM0_DataOut[2];
    IFM1_Shim2[0] <= IFM1_DataOut[2];
    IFM0_Shim3[0] <= IFM0_DataOut[3];
    IFM1_Shim3[0] <= IFM1_DataOut[3];
    IFM0_Shim4[0] <= IFM0_DataOut[4];
    IFM1_Shim4[0] <= IFM1_DataOut[4];
    IFM0_Shim5[0] <= IFM0_DataOut[5];
    IFM1_Shim5[0] <= IFM1_DataOut[5];
    IFM0_Shim6[0] <= IFM0_DataOut[6];
    IFM1_Shim6[0] <= IFM1_DataOut[6];
    IFM0_Shim7[0] <= IFM0_DataOut[7];
    IFM1_Shim7[0] <= IFM1_DataOut[7];
    IFM0_Shim8[0] <= IFM0_DataOut[8];
    IFM1_Shim8[0] <= IFM1_DataOut[8];
    OFM_Shim6 <= OFM_SYSToACC[6];
    OFM_Shim5[0] <= OFM_SYSToACC[5];
    OFM_Shim4[0] <= OFM_SYSToACC[4];
    OFM_Shim3[0] <= OFM_SYSToACC[3];
    OFM_Shim2[0] <= OFM_SYSToACC[2];
    OFM_Shim1[0] <= OFM_SYSToACC[1];
    OFM_Shim0[0] <= OFM_SYSToACC[0];

    for (shimIdx = 1; shimIdx < 2; shimIdx += 1) begin
        IFM0_Shim2[shimIdx] <= IFM0_Shim2[shimIdx-1];
        IFM1_Shim2[shimIdx] <= IFM1_Shim2[shimIdx-1];
        OFM_Shim5[shimIdx] <= OFM_Shim5[shimIdx-1];
    end    
    for (shimIdx = 1; shimIdx < 3; shimIdx += 1) begin
        IFM0_Shim3[shimIdx] <= IFM0_Shim3[shimIdx-1];
        IFM1_Shim3[shimIdx] <= IFM1_Shim3[shimIdx-1];
        OFM_Shim4[shimIdx] <= OFM_Shim4[shimIdx-1];
    end    
    for (shimIdx = 1; shimIdx < 4; shimIdx += 1) begin
        IFM0_Shim4[shimIdx] <= IFM0_Shim4[shimIdx-1];
        IFM1_Shim4[shimIdx] <= IFM1_Shim4[shimIdx-1];
        OFM_Shim3[shimIdx] <= OFM_Shim3[shimIdx-1];
    end    
    for (shimIdx = 1; shimIdx < 5; shimIdx += 1) begin
        IFM0_Shim5[shimIdx] <= IFM0_Shim5[shimIdx-1];
        IFM1_Shim5[shimIdx] <= IFM1_Shim5[shimIdx-1];
        OFM_Shim2[shimIdx] <= OFM_Shim2[shimIdx-1];
    end    
    for (shimIdx = 1; shimIdx < 6; shimIdx += 1) begin
        IFM0_Shim6[shimIdx] <= IFM0_Shim6[shimIdx-1];
        IFM1_Shim6[shimIdx] <= IFM1_Shim6[shimIdx-1];
        OFM_Shim1[shimIdx] <= OFM_Shim1[shimIdx-1];
    end    
    for (shimIdx = 1; shimIdx < 7; shimIdx += 1) begin
        IFM0_Shim7[shimIdx] <= IFM0_Shim7[shimIdx-1];
        IFM1_Shim7[shimIdx] <= IFM1_Shim7[shimIdx-1];
        OFM_Shim0[shimIdx] <= OFM_Shim0[shimIdx-1];
    end    
    for (shimIdx = 1; shimIdx < 8; shimIdx += 1) begin
        IFM0_Shim8[shimIdx] <= IFM0_Shim8[shimIdx-1];
        IFM1_Shim8[shimIdx] <= IFM1_Shim8[shimIdx-1];
    end
end

/* Data to bias and zero point registers */
always_ff @(posedge clk) begin
    if (rst) begin
        for (biasIdx = 0; biasIdx < `NUM_BIAS_REG; biasIdx = biasIdx + 1) begin
            Bias[biasIdx] <= `MAC_OUT_BIT'd0;
        end
    end
    else if (isWriteDataPending && isOrderedToWriteBias) begin
        unique case (sysCounter[3:0])
            4'd0: begin
                Bias[0] <= DI[`MAC_OUT_BIT-1:0];
            end
            4'd1: begin
                Bias[1] <= DI[`MAC_OUT_BIT-1:0];
            end
            4'd2: begin
                Bias[2] <= DI[`MAC_OUT_BIT-1:0];
            end
            4'd3: begin
                Bias[3] <= DI[`MAC_OUT_BIT-1:0];
            end
            4'd4: begin
                Bias[4] <= DI[`MAC_OUT_BIT-1:0];
            end
            4'd5: begin
                Bias[5] <= DI[`MAC_OUT_BIT-1:0];
            end
            4'd6: begin
                Bias[6] <= DI[`MAC_OUT_BIT-1:0];
            end
            4'd7: begin
                Bias[7] <= DI[`MAC_OUT_BIT-1:0];
            end
            default: begin
            end
        endcase
    end
end
always_ff @(posedge clk) begin
    if (rst) begin
        IFM_ZeroPoint <= `IFM_PER_BYTE_BIT'd0;
    end
    else if (isWriteDataPending && isOrderedToWriteBias && sysCounter == {8'b0, sysWidth} + `SYS_COUNTER_BIT'd1) begin
        IFM_ZeroPoint <= DI[`IFM_PER_BYTE_BIT-1:0];
    end
end

/* Input to IFM temporary registers */
always_ff @(posedge clk) begin
    if (rst) begin
        for (inputRowIdx = 0; inputRowIdx < `NUM_INPUT_REG_ROW; inputRowIdx = inputRowIdx + 1) begin
            for (inputPerRowIdx = 0; inputPerRowIdx < `NUM_INPUT_REG_PER_ROW; inputPerRowIdx = inputPerRowIdx + 1) begin
                IFM_InputReg[inputRowIdx][inputPerRowIdx] <= `IFM_PER_BYTE_BIT'd0;
            end
        end
    end
    else if (inputQThreshold) begin
        if (isWriteDataPending) begin
            unique case (inputRowIndex)
            `INPUT_ROW_INDEX_BIT'd0: begin
                `Q_THRES_REG(0) <= DI[7:0];
                `Q_THRES_REG(1) <= DI[15:8];
                `Q_THRES_REG(2) <= DI[23:16];
                `Q_THRES_REG(3) <= DI[39:32];
                `Q_THRES_REG(4) <= DI[47:40];
                `Q_THRES_REG(5) <= DI[55:48];
            end
            `INPUT_ROW_INDEX_BIT'd1: begin
                `Q_THRES_REG(0) <= DI[39:32];
                `Q_THRES_REG(1) <= DI[47:40];
                `Q_THRES_REG(2) <= DI[55:48];
                `Q_THRES_REG(3) <= `Q_THRES_REG(3);
                `Q_THRES_REG(4) <= `Q_THRES_REG(4);
                `Q_THRES_REG(5) <= `Q_THRES_REG(5);
            end
            default: begin
                `Q_THRES_REG(0) <= `Q_THRES_REG(0);
                `Q_THRES_REG(1) <= `Q_THRES_REG(1);
                `Q_THRES_REG(2) <= `Q_THRES_REG(2);
                `Q_THRES_REG(3) <= `Q_THRES_REG(3);
                `Q_THRES_REG(4) <= `Q_THRES_REG(4);
                `Q_THRES_REG(5) <= `Q_THRES_REG(5);
            end
            endcase
        end
    end
    else if (isOrderedToReadOFM && throughQuant) begin
        unique case (qState)
        SORT_1_D: begin
            `OFM_QED_REG(0) <= {thresholdResult[0], 6'd0};
            `OFM_QED_REG(1) <= {thresholdResult[1], 6'd0};
            `OFM_QED_REG(2) <= {thresholdResult[2], 6'd0};
            `OFM_QED_REG(3) <= {thresholdResult[3], 6'd0};
            `OFM_QED_REG(4) <= {thresholdResult[4], 6'd0};
            `OFM_QED_REG(5) <= {thresholdResult[5], 6'd0};
            `OFM_QED_REG(6) <= {thresholdResult[6], 6'd0};
            `OFM_QED_REG(7) <= {thresholdResult[7], 6'd0};
        end
        SORT_2_D: begin
            `OFM_QED_REG(0) <= {`OFM_QED_REG(0)[7:6], thresholdResult[0], 4'd0};
            `OFM_QED_REG(1) <= {`OFM_QED_REG(1)[7:6], thresholdResult[1], 4'd0};
            `OFM_QED_REG(2) <= {`OFM_QED_REG(2)[7:6], thresholdResult[2], 4'd0};
            `OFM_QED_REG(3) <= {`OFM_QED_REG(3)[7:6], thresholdResult[3], 4'd0};
            `OFM_QED_REG(4) <= {`OFM_QED_REG(4)[7:6], thresholdResult[4], 4'd0};
            `OFM_QED_REG(5) <= {`OFM_QED_REG(5)[7:6], thresholdResult[5], 4'd0};
            `OFM_QED_REG(6) <= {`OFM_QED_REG(6)[7:6], thresholdResult[6], 4'd0};
            `OFM_QED_REG(7) <= {`OFM_QED_REG(7)[7:6], thresholdResult[7], 4'd0};
        end
        SORT_3_D: begin
            `OFM_QED_REG(0) <= {`OFM_QED_REG(0)[7:4], thresholdResult[0], 2'd0};
            `OFM_QED_REG(1) <= {`OFM_QED_REG(1)[7:4], thresholdResult[1], 2'd0};
            `OFM_QED_REG(2) <= {`OFM_QED_REG(2)[7:4], thresholdResult[2], 2'd0};
            `OFM_QED_REG(3) <= {`OFM_QED_REG(3)[7:4], thresholdResult[3], 2'd0};
            `OFM_QED_REG(4) <= {`OFM_QED_REG(4)[7:4], thresholdResult[4], 2'd0};
            `OFM_QED_REG(5) <= {`OFM_QED_REG(5)[7:4], thresholdResult[5], 2'd0};
            `OFM_QED_REG(6) <= {`OFM_QED_REG(6)[7:4], thresholdResult[6], 2'd0};
            `OFM_QED_REG(7) <= {`OFM_QED_REG(7)[7:4], thresholdResult[7], 2'd0};
        end
        SORT_4_D: begin
            `OFM_QED_REG(0) <= {`OFM_QED_REG(0)[7:2], thresholdResult[0]};
            `OFM_QED_REG(1) <= {`OFM_QED_REG(1)[7:2], thresholdResult[1]};
            `OFM_QED_REG(2) <= {`OFM_QED_REG(2)[7:2], thresholdResult[2]};
            `OFM_QED_REG(3) <= {`OFM_QED_REG(3)[7:2], thresholdResult[3]};
            `OFM_QED_REG(4) <= {`OFM_QED_REG(4)[7:2], thresholdResult[4]};
            `OFM_QED_REG(5) <= {`OFM_QED_REG(5)[7:2], thresholdResult[5]};
            `OFM_QED_REG(6) <= {`OFM_QED_REG(6)[7:2], thresholdResult[6]};
            `OFM_QED_REG(7) <= {`OFM_QED_REG(7)[7:2], thresholdResult[7]};
        end
        default: begin
            `OFM_QED_REG(0) <= `OFM_QED_REG(0);
            `OFM_QED_REG(1) <= `OFM_QED_REG(1);
            `OFM_QED_REG(2) <= `OFM_QED_REG(2);
            `OFM_QED_REG(3) <= `OFM_QED_REG(3);
            `OFM_QED_REG(4) <= `OFM_QED_REG(4);
            `OFM_QED_REG(5) <= `OFM_QED_REG(5);
            `OFM_QED_REG(6) <= `OFM_QED_REG(6);
            `OFM_QED_REG(7) <= `OFM_QED_REG(7);
        end
        endcase
    end
    else begin
        unique case (inputEnqOffset)
        `INPUT_ENQ_OFFSET_BIT'd0: begin
            IFM_InputReg[inputRowIndex][0] <= DI[7:0];
            IFM_InputReg[inputRowIndex][1] <= DI[15:8];
            IFM_InputReg[inputRowIndex][2] <= DI[23:16];
            IFM_InputReg[inputRowIndex][3] <= DI[31:24];
            IFM_InputReg[inputRowIndex][4] <= DI[39:32];
            IFM_InputReg[inputRowIndex][5] <= DI[47:40];
            IFM_InputReg[inputRowIndex][6] <= DI[55:48];
            IFM_InputReg[inputRowIndex][7] <= DI[63:56];
        end
        `INPUT_ENQ_OFFSET_BIT'd1: begin
            IFM_InputReg[inputRowIndex][8] <= DI[7:0];
            IFM_InputReg[inputRowIndex][9] <= DI[15:8];
            IFM_InputReg[inputRowIndex][10] <= DI[23:16];
            IFM_InputReg[inputRowIndex][11] <= DI[31:24];
            IFM_InputReg[inputRowIndex][12] <= DI[39:32];
            IFM_InputReg[inputRowIndex][13] <= DI[47:40];
            IFM_InputReg[inputRowIndex][14] <= DI[55:48];
            IFM_InputReg[inputRowIndex][15] <= DI[63:56];
        end
        `INPUT_ENQ_OFFSET_BIT'd2: begin
            IFM_InputReg[inputRowIndex][16] <= DI[7:0];
            IFM_InputReg[inputRowIndex][17] <= DI[15:8];
            IFM_InputReg[inputRowIndex][18] <= DI[23:16];
            IFM_InputReg[inputRowIndex][19] <= DI[31:24];
            IFM_InputReg[inputRowIndex][20] <= DI[39:32];
            IFM_InputReg[inputRowIndex][21] <= DI[47:40];
            IFM_InputReg[inputRowIndex][22] <= DI[55:48];
            IFM_InputReg[inputRowIndex][23] <= DI[63:56];
        end
        `INPUT_ENQ_OFFSET_BIT'd3: begin
            IFM_InputReg[inputRowIndex][24] <= DI[7:0];
            IFM_InputReg[inputRowIndex][25] <= DI[15:8];
            IFM_InputReg[inputRowIndex][26] <= DI[23:16];
            IFM_InputReg[inputRowIndex][27] <= DI[31:24];
            IFM_InputReg[inputRowIndex][28] <= DI[39:32];
            IFM_InputReg[inputRowIndex][29] <= DI[47:40];
            IFM_InputReg[inputRowIndex][30] <= DI[55:48];
            IFM_InputReg[inputRowIndex][31] <= DI[63:56];
        end
        `INPUT_ENQ_OFFSET_BIT'd4: begin
            IFM_InputReg[inputRowIndex][32] <= DI[7:0];
            IFM_InputReg[inputRowIndex][33] <= DI[15:8];
            IFM_InputReg[inputRowIndex][34] <= DI[23:16];
            IFM_InputReg[inputRowIndex][35] <= DI[31:24];
            IFM_InputReg[inputRowIndex][36] <= DI[39:32];
            IFM_InputReg[inputRowIndex][37] <= DI[47:40];
            IFM_InputReg[inputRowIndex][38] <= DI[55:48];
            IFM_InputReg[inputRowIndex][39] <= DI[63:56];
        end
        `INPUT_ENQ_OFFSET_BIT'd5: begin
            IFM_InputReg[inputRowIndex][40] <= DI[7:0];
            IFM_InputReg[inputRowIndex][41] <= DI[15:8];
            IFM_InputReg[inputRowIndex][42] <= DI[23:16];
            IFM_InputReg[inputRowIndex][43] <= DI[31:24];
            IFM_InputReg[inputRowIndex][44] <= DI[39:32];
            IFM_InputReg[inputRowIndex][45] <= DI[47:40];
            IFM_InputReg[inputRowIndex][46] <= DI[55:48];
            IFM_InputReg[inputRowIndex][47] <= DI[63:56];
        end
        `INPUT_ENQ_OFFSET_BIT'd6: begin
            IFM_InputReg[inputRowIndex][48] <= DI[7:0];
            IFM_InputReg[inputRowIndex][49] <= DI[15:8];
            IFM_InputReg[inputRowIndex][50] <= DI[23:16];
            IFM_InputReg[inputRowIndex][51] <= DI[31:24];
            IFM_InputReg[inputRowIndex][52] <= DI[39:32];
            IFM_InputReg[inputRowIndex][53] <= DI[47:40];
            IFM_InputReg[inputRowIndex][54] <= DI[55:48];
            IFM_InputReg[inputRowIndex][55] <= DI[63:56];
        end
        `INPUT_ENQ_OFFSET_BIT'd7: begin
            IFM_InputReg[inputRowIndex][56] <= DI[7:0];
            IFM_InputReg[inputRowIndex][57] <= DI[15:8];
            IFM_InputReg[inputRowIndex][58] <= DI[23:16];
            IFM_InputReg[inputRowIndex][59] <= DI[31:24];
            IFM_InputReg[inputRowIndex][60] <= DI[39:32];
        end
        default: begin
            // nothing
        end
        endcase
    end
end
/* Conv input */
// Newest at the most down below
always_comb begin
    // UL
    IFM_ConvInput[0] = (inputUpmostPixelPad || inputLeftmostPixelPad) ? IFM_ZeroPoint : IFM_InputReg[inputRowIndexAdd1][inputDeqOffsetMin1];
    // U
    IFM_ConvInput[1] = (inputUpmostPixelPad) ? IFM_ZeroPoint : IFM_InputReg[inputRowIndexAdd1][inputDeqOffset];
    // UR
    IFM_ConvInput[2] = (inputUpmostPixelPad) ? IFM_ZeroPoint : IFM_InputReg[inputRowIndexAdd1][inputDeqOffsetAdd1];
    // Left
    IFM_ConvInput[3] = (inputLeftmostPixelPad) ? IFM_ZeroPoint : IFM_InputReg[inputRowIndexMin1][inputDeqOffsetMin1];
    // C
    IFM_ConvInput[4] = IFM_InputReg[inputRowIndexMin1][inputDeqOffset];
    // R
    IFM_ConvInput[5] = (inputRightmostPixelPad) ? IFM_ZeroPoint : IFM_InputReg[inputRowIndexMin1][inputDeqOffsetAdd1];
    // LL
    IFM_ConvInput[6] = (inputLeftmostPixelPad || inputLowestPixelPad) ? IFM_ZeroPoint : IFM_InputReg[inputRowIndex][inputDeqOffsetMin1];
    // Lower
    IFM_ConvInput[7] = (inputLowestPixelPad) ? IFM_ZeroPoint : IFM_InputReg[inputRowIndex][inputDeqOffset];
    // LR
    IFM_ConvInput[8] = (inputRightmostPixelPad || inputLowestPixelPad) ? IFM_ZeroPoint : IFM_InputReg[inputRowIndex][inputDeqOffsetAdd1];
end

/* Input to IFM SRAM */
always_comb begin
    if (inputSRAMId == 1'b0) begin
        unique case (inputMode)
        INPUT_MODE_NO_CONV: begin
            IFM0_DataIn[0] = (writeDataEn[0]) ? DI[7:0] : IFM_ZeroPoint;
            IFM0_DataIn[1] = (writeDataEn[1]) ? DI[15:8] : IFM_ZeroPoint;
            IFM0_DataIn[2] = (writeDataEn[2]) ? DI[23:16] : IFM_ZeroPoint;
            IFM0_DataIn[3] = (writeDataEn[3]) ? DI[31:24] : IFM_ZeroPoint;
            IFM0_DataIn[4] = (writeDataEn[4]) ? DI[39:32] : IFM_ZeroPoint;
            IFM0_DataIn[5] = (writeDataEn[5]) ? DI[47:40] : IFM_ZeroPoint;
            IFM0_DataIn[6] = (writeDataEn[6]) ? DI[55:48] : IFM_ZeroPoint;
            IFM0_DataIn[7] = (writeDataEn[7]) ? DI[63:56] : IFM_ZeroPoint;
            IFM0_DataIn[8] = IFM_ZeroPoint;
        end
        INPUT_MODE_CONV2D_S1: begin
            IFM0_DataIn[0] = IFM_ConvInput[0];
            IFM0_DataIn[1] = IFM_ConvInput[1];
            IFM0_DataIn[2] = IFM_ConvInput[2];
            IFM0_DataIn[3] = IFM_ConvInput[3];
            IFM0_DataIn[4] = IFM_ConvInput[4];
            IFM0_DataIn[5] = IFM_ConvInput[5];
            IFM0_DataIn[6] = IFM_ConvInput[6];
            IFM0_DataIn[7] = IFM_ConvInput[7];
            IFM0_DataIn[8] = IFM_ConvInput[8];
        end
        INPUT_MODE_CONV2D_S2: begin
            IFM0_DataIn[0] = IFM_ConvInput[0];
            IFM0_DataIn[1] = IFM_ConvInput[1];
            IFM0_DataIn[2] = IFM_ConvInput[2];
            IFM0_DataIn[3] = IFM_ConvInput[3];
            IFM0_DataIn[4] = IFM_ConvInput[4];
            IFM0_DataIn[5] = IFM_ConvInput[5];
            IFM0_DataIn[6] = IFM_ConvInput[6];
            IFM0_DataIn[7] = IFM_ConvInput[7];
            IFM0_DataIn[8] = IFM_ConvInput[8];
        end
        INPUT_Q_THRES: begin
            IFM0_DataIn[0] = (inputRowIndex[1]) ? `Q_THRES_REG(0)   : `Q_THRES_REG(0);
            IFM0_DataIn[1] = (inputRowIndex[1]) ? `Q_THRES_REG(1)   : `Q_THRES_REG(1);
            IFM0_DataIn[2] = (inputRowIndex[1]) ? `Q_THRES_REG(2)   : `Q_THRES_REG(2);
            IFM0_DataIn[3] = (inputRowIndex[1]) ? DI[7:0]           : `Q_THRES_REG(3);
            IFM0_DataIn[4] = (inputRowIndex[1]) ? DI[15:8]          : `Q_THRES_REG(4);
            IFM0_DataIn[5] = (inputRowIndex[1]) ? DI[23:16]         : `Q_THRES_REG(5);
            IFM0_DataIn[6] = (inputRowIndex[1]) ? DI[39:32]         : DI[7:0];
            IFM0_DataIn[7] = (inputRowIndex[1]) ? DI[47:40]         : DI[15:8];
            IFM0_DataIn[8] = (inputRowIndex[1]) ? DI[55:48]         : DI[23:16];
        end
        default: begin
            IFM0_DataIn[0] = 8'd0;
            IFM0_DataIn[1] = 8'd0;
            IFM0_DataIn[2] = 8'd0;
            IFM0_DataIn[3] = 8'd0;
            IFM0_DataIn[4] = 8'd0;
            IFM0_DataIn[5] = 8'd0;
            IFM0_DataIn[6] = 8'd0;
            IFM0_DataIn[7] = 8'd0;
            IFM0_DataIn[8] = 8'd0;
        end
        endcase
    end
    else begin
        IFM0_DataIn[0] = 8'd0;
        IFM0_DataIn[1] = 8'd0;
        IFM0_DataIn[2] = 8'd0;
        IFM0_DataIn[3] = 8'd0;
        IFM0_DataIn[4] = 8'd0;
        IFM0_DataIn[5] = 8'd0;
        IFM0_DataIn[6] = 8'd0;
        IFM0_DataIn[7] = 8'd0;
        IFM0_DataIn[8] = 8'd0;
    end
end


always_comb begin
    if (inputSRAMId == 1'b1) begin
        unique case (inputMode)
        INPUT_MODE_NO_CONV: begin
            IFM1_DataIn[0] = (writeDataEn[0]) ? DI[7:0] : IFM_ZeroPoint;
            IFM1_DataIn[1] = (writeDataEn[0]) ? DI[15:8] : IFM_ZeroPoint;
            IFM1_DataIn[2] = (writeDataEn[0]) ? DI[23:16] : IFM_ZeroPoint;
            IFM1_DataIn[3] = (writeDataEn[0]) ? DI[31:24] : IFM_ZeroPoint;
            IFM1_DataIn[4] = (writeDataEn[0]) ? DI[39:32] : IFM_ZeroPoint;
            IFM1_DataIn[5] = (writeDataEn[0]) ? DI[47:40] : IFM_ZeroPoint;
            IFM1_DataIn[6] = (writeDataEn[0]) ? DI[55:48] : IFM_ZeroPoint;
            IFM1_DataIn[7] = (writeDataEn[0]) ? DI[63:56] : IFM_ZeroPoint;
            IFM1_DataIn[8] = IFM_ZeroPoint;
        end
        INPUT_MODE_CONV2D_S1: begin
            IFM1_DataIn[0] = IFM_ConvInput[0];
            IFM1_DataIn[1] = IFM_ConvInput[1];
            IFM1_DataIn[2] = IFM_ConvInput[2];
            IFM1_DataIn[3] = IFM_ConvInput[3];
            IFM1_DataIn[4] = IFM_ConvInput[4];
            IFM1_DataIn[5] = IFM_ConvInput[5];
            IFM1_DataIn[6] = IFM_ConvInput[6];
            IFM1_DataIn[7] = IFM_ConvInput[7];
            IFM1_DataIn[8] = IFM_ConvInput[8];
        end
        INPUT_MODE_CONV2D_S2: begin
            IFM1_DataIn[0] = IFM_ConvInput[0];
            IFM1_DataIn[1] = IFM_ConvInput[1];
            IFM1_DataIn[2] = IFM_ConvInput[2];
            IFM1_DataIn[3] = IFM_ConvInput[3];
            IFM1_DataIn[4] = IFM_ConvInput[4];
            IFM1_DataIn[5] = IFM_ConvInput[5];
            IFM1_DataIn[6] = IFM_ConvInput[6];
            IFM1_DataIn[7] = IFM_ConvInput[7];
            IFM1_DataIn[8] = IFM_ConvInput[8];
        end
        default: begin
            IFM1_DataIn[0] = 8'd0;
            IFM1_DataIn[1] = 8'd0;
            IFM1_DataIn[2] = 8'd0;
            IFM1_DataIn[3] = 8'd0;
            IFM1_DataIn[4] = 8'd0;
            IFM1_DataIn[5] = 8'd0;
            IFM1_DataIn[6] = 8'd0;
            IFM1_DataIn[7] = 8'd0;
            IFM1_DataIn[8] = 8'd0;
        end
        endcase
    end
    else begin
        IFM1_DataIn[0] = 8'd0;
        IFM1_DataIn[1] = 8'd0;
        IFM1_DataIn[2] = 8'd0;
        IFM1_DataIn[3] = 8'd0;
        IFM1_DataIn[4] = 8'd0;
        IFM1_DataIn[5] = 8'd0;
        IFM1_DataIn[6] = 8'd0;
        IFM1_DataIn[7] = 8'd0;
        IFM1_DataIn[8] = 8'd0;
    end
end

always_comb begin
    if (inputSRAMId == 1'b0) begin
        unique case (inputMode)
        INPUT_MODE_NO_CONV: begin
            IFM0_WEB[0] = (IFM0_Index == `IFM0_INDEX_BIT'd0) ? 9'd0 : 9'h1ff;
            IFM0_WEB[1] = (IFM0_Index == `IFM0_INDEX_BIT'd1) ? 9'd0 : 9'h1ff;
            IFM0_WEB[2] = (IFM0_Index == `IFM0_INDEX_BIT'd2) ? 9'd0 : 9'h1ff;
            IFM0_WEB[3] = (IFM0_Index == `IFM0_INDEX_BIT'd3) ? 9'd0 : 9'h1ff;
            IFM0_WEB[4] = (IFM0_Index == `IFM0_INDEX_BIT'd4) ? 9'd0 : 9'h1ff;
            IFM0_WEB[5] = (IFM0_Index == `IFM0_INDEX_BIT'd5) ? 9'd0 : 9'h1ff;
            IFM0_WEB[6] = (IFM0_Index == `IFM0_INDEX_BIT'd6) ? 9'd0 : 9'h1ff;
            IFM0_WEB[7] = (IFM0_Index == `IFM0_INDEX_BIT'd7) ? 9'd0 : 9'h1ff;
        end
        INPUT_MODE_CONV2D_S1: begin
            IFM0_WEB[0] = (IFM0_Index == `IFM0_INDEX_BIT'd0) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
            IFM0_WEB[1] = (IFM0_Index == `IFM0_INDEX_BIT'd1) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
            IFM0_WEB[2] = (IFM0_Index == `IFM0_INDEX_BIT'd2) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
            IFM0_WEB[3] = (IFM0_Index == `IFM0_INDEX_BIT'd3) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
            IFM0_WEB[4] = (IFM0_Index == `IFM0_INDEX_BIT'd4) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
            IFM0_WEB[5] = (IFM0_Index == `IFM0_INDEX_BIT'd5) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
            IFM0_WEB[6] = (IFM0_Index == `IFM0_INDEX_BIT'd6) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
            IFM0_WEB[7] = (IFM0_Index == `IFM0_INDEX_BIT'd7) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
        end
        INPUT_MODE_CONV2D_S2: begin
            IFM0_WEB[0] = (IFM0_Index == `IFM0_INDEX_BIT'd0) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
            IFM0_WEB[1] = (IFM0_Index == `IFM0_INDEX_BIT'd1) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
            IFM0_WEB[2] = (IFM0_Index == `IFM0_INDEX_BIT'd2) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
            IFM0_WEB[3] = (IFM0_Index == `IFM0_INDEX_BIT'd3) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
            IFM0_WEB[4] = (IFM0_Index == `IFM0_INDEX_BIT'd4) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
            IFM0_WEB[5] = (IFM0_Index == `IFM0_INDEX_BIT'd5) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
            IFM0_WEB[6] = (IFM0_Index == `IFM0_INDEX_BIT'd6) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
            IFM0_WEB[7] = (IFM0_Index == `IFM0_INDEX_BIT'd7) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
        end
        INPUT_Q_THRES: begin
            IFM0_WEB[0] = 9'h0;
            IFM0_WEB[1] = 9'h0;
            IFM0_WEB[2] = 9'h0;
            IFM0_WEB[3] = 9'h0;
            IFM0_WEB[4] = 9'h0;
            IFM0_WEB[5] = 9'h0;
            IFM0_WEB[6] = 9'h0;
            IFM0_WEB[7] = 9'h0;
        end
        default: begin
            IFM0_WEB[0] = 9'h1ff;
            IFM0_WEB[1] = 9'h1ff;
            IFM0_WEB[2] = 9'h1ff;
            IFM0_WEB[3] = 9'h1ff;
            IFM0_WEB[4] = 9'h1ff;
            IFM0_WEB[5] = 9'h1ff;
            IFM0_WEB[6] = 9'h1ff;
            IFM0_WEB[7] = 9'h1ff;
        end
        endcase
    end
    else begin
        IFM0_WEB[0] = 9'h1ff;
        IFM0_WEB[1] = 9'h1ff;
        IFM0_WEB[2] = 9'h1ff;
        IFM0_WEB[3] = 9'h1ff;
        IFM0_WEB[4] = 9'h1ff;
        IFM0_WEB[5] = 9'h1ff;
        IFM0_WEB[6] = 9'h1ff;
        IFM0_WEB[7] = 9'h1ff;
    end
end

always_comb begin
    unique case (inputMode)
    INPUT_MODE_NO_CONV: begin
        IFM1_WEB = (inputSRAMId == 1'b1) ? 9'd0 : 9'h1ff;
    end
    INPUT_MODE_CONV2D_S1: begin
        IFM1_WEB = (inputSRAMId == 1'b1) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
    end
    INPUT_MODE_CONV2D_S2: begin
        IFM1_WEB = (inputSRAMId == 1'b1) ? ~{9{isWritingInputSRAMConv}} : 9'h1ff;
    end
    default: begin
        IFM1_WEB = 9'h1ff;
    end
    endcase
end

/* In case we can't use 16-bit as bit width of partial sum, 
    only 2 raw OFM data would be transmitted at once */
always_comb begin
    if (!throughQuant) begin
        if (rowOrCol == ROW) begin
            unique case (sysCounter[2:0])
            3'd0: begin
                DO = {{8{OFM_SRAMOutput[1][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[1], 
                      {8{OFM_SRAMOutput[0][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[0]};
            end
            3'd1: begin
                DO = {{8{OFM_SRAMOutput[3][`MAC_OUT_BIT-1]}},
                      OFM_SRAMOutput[3], 
                      {8{OFM_SRAMOutput[2][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[2]};
            end
            3'd2: begin
                DO = {{8{OFM_SRAMOutput[5][`MAC_OUT_BIT-1]}},
                      OFM_SRAMOutput[5], 
                      {8{OFM_SRAMOutput[4][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[4]};
            end
            3'd3: begin
                DO = {{8{OFM_SRAMOutput[7][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[7], 
                      {8{OFM_SRAMOutput[6][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[6]};
            end
            3'd4: begin
                DO = {{8{OFM_SRAMOutput[9][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[9], 
                      {8{OFM_SRAMOutput[8][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[8]};
            end
            3'd5: begin
                DO = {{8{OFM_SRAMOutput[11][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[11],
                      {8{OFM_SRAMOutput[10][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[10]};
            end
            3'd6: begin
                DO = {{8{OFM_SRAMOutput[13][`MAC_OUT_BIT-1]}},
                      OFM_SRAMOutput[13],
                      {8{OFM_SRAMOutput[12][`MAC_OUT_BIT-1]}},
                      OFM_SRAMOutput[12]};
            end
            3'd7: begin
                DO = {{8{OFM_SRAMOutput[15][`MAC_OUT_BIT-1]}},
                      OFM_SRAMOutput[15],
                      {8{OFM_SRAMOutput[14][`MAC_OUT_BIT-1]}},
                      OFM_SRAMOutput[14]};
            end
            endcase
        end
        else begin
            unique case (sysCounter[2:0])
            3'd0: begin
                DO = {{8{OFM_SRAMOutput[8][`MAC_OUT_BIT-1]}},
                      OFM_SRAMOutput[8], 
                      {8{OFM_SRAMOutput[0][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[0]};
            end
            3'd1: begin
                DO = {{8{OFM_SRAMOutput[9][`MAC_OUT_BIT-1]}},
                      OFM_SRAMOutput[9], 
                      {8{OFM_SRAMOutput[1][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[1]};
            end
            3'd2: begin
                DO = {{8{OFM_SRAMOutput[10][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[10], 
                      {8{OFM_SRAMOutput[2][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[2]};
            end
            3'd3: begin
                DO = {{8{OFM_SRAMOutput[11][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[11], 
                      {8{OFM_SRAMOutput[3][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[3]};
            end
            3'd4: begin
                DO = {{8{OFM_SRAMOutput[12][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[12], 
                      {8{OFM_SRAMOutput[4][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[4]};
            end
            3'd5: begin
                DO = {{8{OFM_SRAMOutput[13][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[13], 
                      {8{OFM_SRAMOutput[5][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[5]};
            end
            3'd6: begin
                DO = {{8{OFM_SRAMOutput[14][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[14], 
                      {8{OFM_SRAMOutput[6][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[6]};
            end
            3'd7: begin
                DO = {{8{OFM_SRAMOutput[15][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[15], 
                      {8{OFM_SRAMOutput[7][`MAC_OUT_BIT-1]}}, 
                      OFM_SRAMOutput[7]};
            end
            endcase
        end
    end
    else begin
        if (qState == SORT_4_D) begin
            DO = {`OFM_QED_REG(7)[7:2],thresholdResult[7],
                  `OFM_QED_REG(6)[7:2],thresholdResult[6],
                  `OFM_QED_REG(5)[7:2],thresholdResult[5],
                  `OFM_QED_REG(4)[7:2],thresholdResult[4],
                  `OFM_QED_REG(3)[7:2],thresholdResult[3],
                  `OFM_QED_REG(2)[7:2],thresholdResult[2],
                  `OFM_QED_REG(1)[7:2],thresholdResult[1],
                  `OFM_QED_REG(0)[7:2],thresholdResult[0]};
        end
        else begin
            DO = {`OFM_QED_REG(7),
                  `OFM_QED_REG(6),
                  `OFM_QED_REG(5),
                  `OFM_QED_REG(4),
                  `OFM_QED_REG(3),
                  `OFM_QED_REG(2),
                  `OFM_QED_REG(1),
                  `OFM_QED_REG(0)};
        end
    end
end

systolic_arr SYS_ARR(
    .clk(clk),
    .rst(rst),
    .isW(isLoadingWeight),
    .IFM_FromSRAM(IFM_SRAMToSYS),
    .W_FromSRAM(W_SRAMToSYS),
    .OFM_ToSRAM(OFM_SYSToACC)
);

IFM_wrapper_short IFM_SRAM0_0 (
    .CK(clk),
    .A(IFM0_Split_Addr[0]),
    .DI(IFM0_DataIn),
    .WEB(IFM0_WEB[0]),
    .OE(!consumeIFMId),
    .CS(1'b1),
    .DO(IFM0_Split_DataOut[0])
);
IFM_wrapper_short IFM_SRAM0_1 (
    .CK(clk),
    .A(IFM0_Split_Addr[1]),
    .DI(IFM0_DataIn),
    .WEB(IFM0_WEB[1]),
    .OE(!consumeIFMId),
    .CS(1'b1),
    .DO(IFM0_Split_DataOut[1])
);
IFM_wrapper_short IFM_SRAM0_2 (
    .CK(clk),
    .A(IFM0_Split_Addr[2]),
    .DI(IFM0_DataIn),
    .WEB(IFM0_WEB[2]),
    .OE(!consumeIFMId),
    .CS(1'b1),
    .DO(IFM0_Split_DataOut[2])
);
IFM_wrapper_short IFM_SRAM0_3 (
    .CK(clk),
    .A(IFM0_Split_Addr[3]),
    .DI(IFM0_DataIn),
    .WEB(IFM0_WEB[3]),
    .OE(!consumeIFMId),
    .CS(1'b1),
    .DO(IFM0_Split_DataOut[3])
);
IFM_wrapper_short IFM_SRAM0_4 (
    .CK(clk),
    .A(IFM0_Split_Addr[4]),
    .DI(IFM0_DataIn),
    .WEB(IFM0_WEB[4]),
    .OE(!consumeIFMId),
    .CS(1'b1),
    .DO(IFM0_Split_DataOut[4])
);
IFM_wrapper_short IFM_SRAM0_5 (
    .CK(clk),
    .A(IFM0_Split_Addr[5]),
    .DI(IFM0_DataIn),
    .WEB(IFM0_WEB[5]),
    .OE(!consumeIFMId),
    .CS(1'b1),
    .DO(IFM0_Split_DataOut[5])
);
IFM_wrapper_short IFM_SRAM0_6 (
    .CK(clk),
    .A(IFM0_Split_Addr[6]),
    .DI(IFM0_DataIn),
    .WEB(IFM0_WEB[6]),
    .OE(!consumeIFMId),
    .CS(1'b1),
    .DO(IFM0_Split_DataOut[6])
);
IFM_wrapper_mid IFM_SRAM0_7 (
    .CK(clk),
    .A(IFM0_Split_Addr_7),
    .DI(IFM0_DataIn),
    .WEB(IFM0_WEB[7]),
    .OE(!consumeIFMId),
    .CS(1'b1),
    .DO(IFM0_Split_DataOut[7])
);
IFM_wrapper IFM_SRAM1 (
    .CK(clk),
    .A(IFM1_Addr),
    .DI(IFM1_DataIn),
    .WEB(IFM1_WEB),
    .OE(consumeIFMId),
    .CS(1'b1),
    .DO(IFM1_DataOut)
);

OFM_wrapper OFM_SRAM0 (
    .CK(clk),
    .A(OFM_Addr),
    .DI(OFM_ACCToSRAM[0:7]),
    .WEB(OFM0_WEB),
    .OE(OFM_OE),
    .CS(1'b1),
    .DO(OFM_SRAMOutput[0:7])
);
OFM_wrapper OFM_SRAM1 (
    .CK(clk),
    .A(OFM_Addr),
    .DI(OFM_ACCToSRAM[8:15]),
    .WEB(OFM1_WEB),
    .OE(OFM_OE),
    .CS(1'b1),
    .DO(OFM_SRAMOutput[8:15])
);

Weight_wrapper W_SRAM (
    .CK(clk),
    .A(W_Addr),
    .DI(W_DataIn),
    .WEB(W_WEB),
    .OE(isLoadingWeight),
    .CS(1'b1),
    .DO(W_DataOut)
);
endmodule