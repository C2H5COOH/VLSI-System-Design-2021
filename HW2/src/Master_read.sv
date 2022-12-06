// `include "../../../include/AXI_define.svh"
`include "../include/AXI_define.svh"

`define READ_IDLE            2'b00
`define READ_WAIT_ARREADY    2'b01
`define READ_WAIT_RVALID     2'b10
`define READ_DEFAULT         2'b11

module MasterRead(
    input                       clk,rst,

    input [31:0]                address, 
    input                       read,

    output logic                        stall,
    output logic [31:0]                 data,

    output logic [`AXI_ID_BITS-1:0]     ARID,
    output logic [`AXI_ADDR_BITS-1:0]   ARADDR,
    output logic [`AXI_LEN_BITS-1:0]    ARLEN,
    output logic [`AXI_SIZE_BITS-1:0]   ARSIZE,
    output logic [1:0]                  ARBURST, //only INCR type
    output logic                        ARVALID,
    input                       ARREADY,



    input [`AXI_ID_BITS-1:0]    RID,
    input [`AXI_DATA_BITS-1:0]  RDATA,
    input [1:0]                 RRESP,
    input                       RLAST,
    input                       RVALID,
    output logic                        RREADY                    
);

parameter master_read = 0;

logic [1:0] state,nstate;

logic [`AXI_ID_BITS-1:0]   ARID_reg;
logic [`AXI_ADDR_BITS-1:0] ARADDR_reg;
logic [`AXI_LEN_BITS-1:0]  ARLEN_reg;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_reg;
logic [1:0]                ARBURST_reg; //only INCR type
logic                      ARVALID_reg;

//next state logic
always_comb begin
    case(state)
        `READ_IDLE : begin
            if(read) begin
				if(ARREADY) nstate = `READ_WAIT_RVALID;    
				else	nstate = `READ_WAIT_ARREADY;
			end
            else        nstate = `READ_IDLE;
        end

        `READ_WAIT_ARREADY : begin
            if(ARREADY) nstate = `READ_WAIT_RVALID;
            else        nstate = `READ_WAIT_ARREADY;
        end

        `READ_WAIT_RVALID : begin
            if(RVALID && RLAST)
                nstate = `READ_IDLE;
            else 
                nstate = `READ_WAIT_RVALID;
        end

        default : nstate = `READ_DEFAULT;
    endcase
end

//state transition
always_ff @(posedge clk) begin
    if(rst) state <= `READ_IDLE;
    else begin
        state <= nstate;
    end
end

//combinational output
always_comb begin
    case(state)
        `READ_IDLE : begin
            ARID    = 4'b0;
            ARADDR  = address;
            ARLEN   = 4'd0; 
            ARSIZE  = 3'b010;
            ARBURST = 2'b01;
            ARVALID = read;

            RREADY  = 1'b0;
            data    = 32'b0;
            stall   = (read == 0)? 1'b0 : 1'b1;
        end
        `READ_WAIT_ARREADY : begin
            ARID    = ARID_reg;
            ARADDR  = ARADDR_reg;
            ARLEN   = ARLEN_reg;
            ARSIZE  = ARSIZE_reg;
            ARBURST = ARBURST_reg;
            ARVALID = ARVALID_reg;

            RREADY  = 1'b0;
            data    = 32'b0;
            stall   = 1'b1;
        end
        `READ_WAIT_RVALID : begin
            ARID    = 4'b0;
            ARADDR  = 32'b0;
            ARLEN   = 4'b0;
            ARSIZE  = 3'b0;
            ARBURST = 2'b0;
            ARVALID = 1'b0;

            RREADY  = 1'b1;

            if(RVALID && RLAST && (RRESP != `AXI_RESP_DECERR) ) begin
                data = RDATA;
                stall = 1'b0;
            end
            else begin
                data = 32'b0;
                stall = 1'b1;
            end
        end
        default : begin
            ARID    = 4'b0;
            ARADDR  = 32'b0;
            ARLEN   = 4'b0;
            ARSIZE  = 3'b0;
            ARBURST = 2'b0;
            ARVALID = 1'b0;

            RREADY  = 1'b0;
            data    = 32'b0;
            stall   = 1'b0;
        end
    endcase
end

//registers
always_ff @(posedge clk) begin
    if(rst)begin
        ARID_reg    <= 4'b0;
        ARADDR_reg  <= 32'b0;
        ARLEN_reg   <= 4'b0;
        ARSIZE_reg  <= 3'b0;
        ARBURST_reg <= 2'b0;
        ARVALID_reg <= 1'b0;
    end
    else begin
        case(state)

            `READ_IDLE : begin
                //if(read) begin
                    ARID_reg    <= ARID;
                    ARADDR_reg  <= ARADDR;
                    ARLEN_reg   <= ARLEN;
                    ARSIZE_reg  <= ARSIZE;
                    ARBURST_reg <= ARBURST;
                    ARVALID_reg <= ARVALID;
                //end
                //else ;                   
            end

            `READ_WAIT_ARREADY : ;
            `READ_WAIT_RVALID : begin
                if(RVALID) begin
                    ARID_reg    <= 4'b0;
                    ARADDR_reg  <= 32'b0;
                    ARLEN_reg   <= 4'b0;
                    ARSIZE_reg  <= 3'b0;
                    ARBURST_reg <= 2'b0;
                    ARVALID_reg <= 1'b0; 
                end
                else ;
            end
            default : begin
                ARID_reg    <= 4'b0;
                ARADDR_reg  <= 32'b0;
                ARLEN_reg   <= 4'b0;
                ARSIZE_reg  <= 3'b0;
                ARBURST_reg <= 2'b0;
                ARVALID_reg <= 1'b0;                    
            end//ERROR state

        endcase
    end
end

endmodule
