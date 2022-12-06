`include "AXI_def.svh"
`include "MEM_def.svh"

module ROM_wrapper (
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
    //ROM Pins
    output logic                        CS,
    output logic                        OE,
    output logic [`ROM_ADDR_BITS-1:0]   addrToROM,
    input  [`ROM_DATA_BITS-1:0]         dataFromROM
);

//64 bits (8 bytes) / trans:
//  3 bits  offset
//  1 bit   burst count
//  8       address
logic [`ROM_ADDR_BITS-1:1]  Addr_reg;
ROM_State                   cStateROM, nStateROM;
logic                       read_finish, read_finish_reg;
logic                       ARLen_reg,
                            read_cnt,
                            read_cnt_1;
logic [`AXI_DATA_BITS-1:0]  dataFromROM_reg;


/* State Machine */
always_ff @( posedge clk or posedge rst) begin
    if (rst) begin
        cStateROM <= ROM_Idle;
    end
    else begin
        cStateROM <= nStateROM;        
    end
end
always_comb begin
    unique case (cStateROM)
    ROM_Idle: begin
        if (ARValid) begin
            nStateROM = ROM_Addr;
        end
        else begin
            nStateROM = ROM_Idle;
        end
    end
    ROM_Addr: begin
        nStateROM = ROM_DataLatch;
    end
    ROM_DataLatch: begin
        nStateROM = ROM_DataOut;
    end
    ROM_DataOut: begin
        nStateROM = (read_finish_reg) ? ROM_Idle : ROM_DataOut;
    end
    default: begin
        nStateROM = ROM_Idle;
    end
    endcase
end

assign read_cnt_1 = !read_cnt;

always_ff @( posedge clk or posedge rst) begin
    if (rst) begin
        read_cnt <= 1'b0;
    end
    else if(cStateROM == ROM_Idle && ARReady) begin
        read_cnt <= 1'b0;
    end
    else if((cStateROM != ROM_Idle) && RReady) begin
        read_cnt <= read_cnt_1;
    end
end

always_ff @(posedge clk) begin
    read_finish <= (read_cnt == ARLen_reg);
    read_finish_reg <= read_finish;
end

always_ff @(posedge clk) begin
    dataFromROM_reg <= dataFromROM;
end

always_comb begin
    addrToROM = {Addr_reg, read_cnt};
end

always_ff @( posedge clk ) begin
    if (rst) begin
        Addr_reg <= {`ROM_ADDR_BITS-1{1'b0}};
        ARLen_reg <= 1'd0;
    end
    else if(cStateROM == ROM_Idle && ARReady) begin
        // 14:4
        Addr_reg <= ARAddr[`ROM_ADDR_BITS+`ROM_CNT_OFFSET-1:`ROM_CNT_OFFSET+1];
        ARLen_reg <= ARLen[0];
    end
end

/* Global Signal */
assign CS = 1'b1;
assign RResp = `AXI_RESP_OKAY;
assign RData = dataFromROM_reg;

/* AR R Channel */
assign  ARReady = (ARValid && cStateROM == ROM_Idle);

always_ff @( posedge clk ) begin
    if (ARValid & ARReady) begin
        RId <= ARId;
    end
end

assign RValid = (cStateROM == ROM_DataOut);
// assign OE     = (cStateROM == ROM_DataOut);
assign OE     = 1'b1;
assign RLast  = (cStateROM == ROM_DataOut && read_finish_reg);
endmodule
