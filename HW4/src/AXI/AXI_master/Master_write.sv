// `include "../../../include/AXI_define.svh"
`include "../include/AXI_define.svh"

`define WRITE_IDLE          3'd0
`define WRITE_WAIT_AWREADY  3'd1
`define WRITE_WAIT_WREADY   3'd2
`define WRITE_WAIT_BVALID   3'd3
`define WRITE_DEFAULT       3'd4

module MasterWrite(
    input                       clk,rst,

    output logic                        stall,

    output logic [`AXI_ID_BITS-1:0]     AWID,
    output logic [`AXI_ADDR_BITS-1:0]   AWADDR,
    output logic [`AXI_LEN_BITS-1:0]    AWLEN,
    output logic [`AXI_SIZE_BITS-1:0]   AWSIZE,
    output logic [1:0]                  AWBURST, //only INCR type
    output logic                        AWVALID,
    input                       AWREADY,

    output logic [`AXI_DATA_BITS-1:0]   WDATA,
    output logic [`AXI_STRB_BITS-1:0]   WSTRB,
    output logic                        WLAST,
    output logic                        WVALID,
    input                       WREADY, 

    input [`AXI_ID_BITS-1:0]    BID,
    input [1:0]                 BRESP,
    input                       BVALID,
    output logic                BREADY, 

    input [31:0]                address, 
    input [3:0]                 write,
    input [`AXI_DATA_BITS-1:0]  data                  
);

parameter master_write = 0;

logic [2:0] state,nstate;

logic [`AXI_ID_BITS-1:0]    AWID_reg;
logic [`AXI_ADDR_BITS-1:0]  AWADDR_reg;
logic [`AXI_LEN_BITS-1:0]   AWLEN_reg;
logic [`AXI_SIZE_BITS-1:0]  AWSIZE_reg;
logic [1:0]                 AWBURST_reg; //only INCR type
logic                       AWVALID_reg;    

logic [`AXI_DATA_BITS-1:0]  WDATA_reg;
logic [`AXI_STRB_BITS-1:0]  WSTRB_reg;
logic                       WLAST_reg;
logic                       WVALID_reg;

//next state logic
always_comb begin
    case(state)
        `WRITE_IDLE : begin
            if(write!=4'b1111) begin //discover write request
				if(AWREADY && WREADY)   nstate = `WRITE_WAIT_BVALID;
                else if(AWREADY)        nstate = `WRITE_WAIT_WREADY;
                else                    nstate = `WRITE_WAIT_AWREADY;
			end
            else
                nstate = `WRITE_IDLE;
        end

        `WRITE_WAIT_AWREADY : begin
            if(AWREADY && WREADY)   nstate = `WRITE_WAIT_BVALID;
            else if(AWREADY)        nstate = `WRITE_WAIT_WREADY;
            else                    nstate = `WRITE_WAIT_AWREADY;
        end

        `WRITE_WAIT_WREADY : begin
            if(WREADY)
                nstate = `WRITE_WAIT_BVALID;
            else
                nstate = `WRITE_WAIT_WREADY;
        end

        `WRITE_WAIT_BVALID : begin
            if(BVALID)
                nstate = `WRITE_IDLE;
            else 
                nstate = `WRITE_WAIT_BVALID;
        end

        default : nstate = `WRITE_DEFAULT;
    endcase
end

//state transition
always_ff @(posedge clk) begin
    if(rst) 
        state <= `WRITE_IDLE;
    else
        state <= nstate;
end

//combinational output
always_comb begin
    case(state)
        `WRITE_IDLE : begin
            AWID    = 4'b0;
            AWADDR  = address;//m0 only to s0, m1 only to s1
            AWLEN   = 4'd0;//no burst
            AWSIZE  = 3'b010;//4bytes per transfer
            AWBURST = 2'b01;//only INCR
            AWVALID = (write == 4'b1111)? 1'b0 : 1'b1;

            WDATA   = (AWVALID && AWREADY)? data : 32'd0;
            WSTRB   = (AWVALID && AWREADY)? ~write : 4'b0000;//in AXI spec, WSTRB is active high
            WLAST   = (AWVALID && AWREADY)? 1'b1 : 1'b0;
            WVALID  = (AWVALID && AWREADY)? 1'b1 : 1'b0;

            BREADY  = 1'b0;
            stall   = (write == 4'b1111)? 1'b0 : 1'b1;
        end

        `WRITE_WAIT_AWREADY : begin
	        AWID    = AWID_reg;
	        AWADDR  = AWADDR_reg;
	        AWLEN   = AWLEN_reg;
	        AWSIZE  = AWSIZE_reg;
	        AWBURST = AWBURST_reg;
	        AWVALID = AWVALID_reg;
		
            WDATA   = (AWVALID && AWREADY)? data : 32'd0;
            WSTRB   = (AWVALID && AWREADY)? ~write : 4'b0000;//in AXI spec, WSTRB is active high
            WLAST   = (AWVALID && AWREADY)? 1'b1 : 1'b0;
            WVALID  = (AWVALID && AWREADY)? 1'b1 : 1'b0;

            BREADY  = 1'b0;
            stall   = 1'b1;
        end

        `WRITE_WAIT_WREADY : begin
	        AWID    = 4'b0;
	        AWADDR  = 32'b0;
	        AWLEN   = 4'b0;
	        AWSIZE  = 3'b0;
	        AWBURST = 2'b0;
	        AWVALID = 1'b0;
		
            WDATA   = WDATA_reg;
            WSTRB   = WSTRB_reg;
            WLAST   = WLAST_reg;
            WVALID  = WVALID_reg;

            BREADY  = 1'b0;
            stall   = 1'b1;
        end

        `WRITE_WAIT_BVALID : begin
            AWID    = 4'b0;
            AWADDR  = 32'b0;
            AWLEN   = 4'b0;
            AWSIZE  = 3'b0;
            AWBURST = 2'b0;
            AWVALID = 1'b0;

            WDATA   = 32'b0;
            WSTRB   = 4'b0;
            WLAST   = 1'b0;
            WVALID  = 1'b0;

            BREADY  = 1'b1;

            if(BVALID && (BRESP != `AXI_RESP_DECERR) ) begin
                stall = 1'b0;
            end
            else begin
                stall = 1'b1;
            end
        end

        default : begin
            AWID    = 4'b0;
            AWADDR  = 32'b0;
            AWLEN   = 4'b0;
            AWSIZE  = 3'b0;
            AWBURST = 2'b0;
            AWVALID = 1'b0;

            WDATA   = 32'b0;
            WSTRB   = 4'b0;
            WLAST   = 1'b0;
            WVALID  = 1'b0;

            BREADY  = 1'b0;
            stall   = 1'b0;              
        end
    endcase
end

//registers
always_ff @(posedge clk) begin
    if(rst)begin
        AWID_reg        <= 4'b0;
        AWADDR_reg      <= 32'b0;
        AWLEN_reg       <= 4'b0;
        AWSIZE_reg      <= 3'b0;
        AWBURST_reg     <= 2'b0;
        AWVALID_reg     <= 1'b0;

        WDATA_reg       <= 32'b0;
        WSTRB_reg       <= 4'b0;
        WLAST_reg       <= 1'b0;
        WVALID_reg      <= 1'b0;
    end
    else begin
        case(state)
            `WRITE_IDLE : begin
                
                AWID_reg        <= AWID;
                AWADDR_reg      <= AWADDR;
                AWLEN_reg       <= AWLEN;
                AWSIZE_reg      <= AWSIZE;
                AWBURST_reg     <= AWBURST;
                AWVALID_reg     <= AWVALID;

                WDATA_reg       <= WDATA;
                WSTRB_reg       <= WSTRB;
                WLAST_reg       <= WLAST;
                WVALID_reg      <= WVALID;               

            end

            `WRITE_WAIT_AWREADY : begin
                WDATA_reg       <= WDATA;
                WSTRB_reg       <= WSTRB;
                WLAST_reg       <= WLAST;
                WVALID_reg      <= WVALID; 
            end

            `WRITE_WAIT_WREADY : ;

            `WRITE_WAIT_BVALID : begin //All handshake complete, clean
                AWID_reg        <= 4'b0;
                AWADDR_reg      <= 32'b0;
                AWLEN_reg       <= 4'b0;
                AWSIZE_reg      <= 3'b0;
                AWBURST_reg     <= 2'b0;
                AWVALID_reg     <= 1'b0;

                WDATA_reg       <= 32'b0;
                WSTRB_reg       <= 4'b0;
                WLAST_reg       <= 1'b0;
                WVALID_reg      <= 1'b0; 
            end

            default : begin
                AWID_reg        <= 4'b0;
                AWADDR_reg      <= 32'b0;
                AWLEN_reg       <= 4'b0;
                AWSIZE_reg      <= 3'b0;
                AWBURST_reg     <= 2'b0;
                AWVALID_reg     <= 1'b0;

                WDATA_reg       <= 32'b0;
                WSTRB_reg       <= 4'b0;
                WLAST_reg       <= 1'b0;
                WVALID_reg      <= 1'b0;
            end
        endcase
    end
end
    
endmodule   
