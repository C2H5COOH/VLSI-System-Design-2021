`include "CPU_with_cache.sv"
`include "AXI_def.svh"

module CPU_wrapper (
    input                               clk,
    input                               rst,
    /* AR Channel 0 */
    output logic [`AXI_ID_BITS-1:0]     ARId0,
    output logic [`AXI_ADDR_BITS-1:0]   ARAddr0,
    output logic [`AXI_LEN_BITS-1:0]    ARLen0,
    output logic [`AXI_SIZE_BITS-1:0]   ARSize0,
    output       [`AXI_BURST_BITS-1:0]  ARBurst0,
    output logic                        ARValid0,
    input                               ARReady0,
    /* R Channel 0 */
    input [`AXI_ID_BITS-1:0]            RId0,
    input [`AXI_DATA_BITS-1:0]          RData0,
    input [`AXI_RESP_BITS-1:0]          RResp0,
    input                               RLast0,
    input                               RValid0,
    output logic                        RReady0,
    /* AR Channel 1 */
    output logic [`AXI_ID_BITS-1:0]     ARId1,
    output logic [`AXI_ADDR_BITS-1:0]   ARAddr1,
    output logic [`AXI_LEN_BITS-1:0]    ARLen1,
    output logic [`AXI_SIZE_BITS-1:0]   ARSize1,
    output       [`AXI_BURST_BITS-1:0]  ARBurst1,
    output logic                        ARValid1,
    input                               ARReady1,
    /* R Channel 1 */
    input [`AXI_ID_BITS-1:0]            RId1,
    input [`AXI_DATA_BITS-1:0]          RData1,
    input [`AXI_RESP_BITS-1:0]          RResp1,
    input                               RLast1,
    input                               RValid1,
    output logic                        RReady1,
    /* AW Channel 1 */
    output logic [`AXI_ID_BITS-1:0]     AWId1,
    output logic [`AXI_ADDR_BITS-1:0]   AWAddr1,
    output logic [`AXI_LEN_BITS-1:0]    AWLen1,
    output logic [`AXI_SIZE_BITS-1:0]   AWSize1,
    output logic [`AXI_BURST_BITS-1:0]  AWBurst1,
    output logic                        AWValid1,
    input                               AWReady1,
    /* W Channel 1 */
    output logic [`AXI_DATA_BITS-1:0]   WData1,
    output logic [`AXI_STRB_BITS-1:0]   WStrb1,
    output logic                        WLast1,
    output logic                        WValid1,
    input                               WReady1,
    /* B Channel 1 */
    input [`AXI_ID_BITS-1:0]            BId1,
    input [`AXI_RESP_BITS-1:0]          BResp1,
    input                               BValid1,
    output logic                        BReady1,

    input                               extern_interrupt
);

localparam Inst_Idle    = 2'b00;
localparam Inst_ARValid = 2'b01;
localparam Inst_RReady  = 2'b10;

localparam Data_Idle       =   3'd0;
localparam Data_ARValid    =   3'd1;
localparam Data_RReady     =   3'd2;
localparam Data_AW_WValid  =   3'd3;
localparam Data_WValid     =   3'd4;
localparam Data_BReady     =   3'd5;

logic [1:0]     cStateInst, nStateInst;
logic I_wait;
logic I_valid;
logic I_req;
logic I_write;
logic [`AXI_DATA_BITS-1:0]    I_out;
logic [31:0]    I_addr, I_addr_reg;

logic [2:0]     cStateMem, nStateMem;
logic           D_read_req, D_write_req;
logic D_wait;
logic D_valid;
logic D_req;
logic D_write;
logic D_burst;
logic [2:0]                 D_type, D_type_reg, D_type_out;
logic [`AXI_STRB_BITS-1:0]  D_strobe,  D_strobe_reg, D_strobe_out;
logic [`AXI_STRB_BITS-1:0]  D_strobe_b;
logic [`AXI_DATA_BITS-1:0]  D_out;
logic [31:0]                D_addr, D_addr_reg, D_addr_out;
logic [`AXI_DATA_BITS-1:0]  D_in, D_in_reg, D_in_out;


logic lastReset;
always_ff @( posedge clk ) begin
    lastReset <= rst;
end

/* Master 0 */

always_ff @( posedge clk ) begin
	cStateInst <= nStateInst;
end
always_comb begin
    if (rst || lastReset) begin
        nStateInst = Inst_Idle;
    end
    else begin
        case (cStateInst)
        Inst_Idle: begin
            if (I_req && ARReady0) begin
                nStateInst = Inst_RReady;
            end
            else if (I_req && !ARReady0) begin
                nStateInst = Inst_ARValid;
            end
            else begin
                nStateInst = Inst_Idle;
            end
        end
        Inst_ARValid: begin
			if (ARReady0) begin
				nStateInst = Inst_RReady;
			end
			else begin
				nStateInst = Inst_ARValid;
			end
        end
        Inst_RReady: begin
			if (RValid0 & RLast0) begin
				nStateInst = Inst_Idle;
			end
			else begin
				nStateInst = Inst_RReady;
			end
        end
        default: begin
            nStateInst = Inst_Idle;
        end
        endcase
    end
end

// signal to cache
assign I_valid  = RValid0;
assign I_out    = RData0;

always_comb begin
    if(cStateInst == Inst_Idle) begin
        if(I_req) begin
            if(ARValid0 && ARReady0)
                I_wait = 1'b0;
            else
                I_wait = 1'b1;
        end
        else begin
            I_wait = 1'b0;
        end            
    end
    else
        I_wait = 1'b1;
end

/* AR Channe 0 */
assign ARId0 = 4'd0;
assign ARLen0 = 4'd1;
assign ARSize0 = 3'd3;
assign ARBurst0 = `AXI_BURST_INCR;
always_comb begin
	case (cStateInst) 
	Inst_Idle: begin
		ARValid0 = I_req & !lastReset;
	end
	Inst_ARValid: begin
		ARValid0 = 1'b1;
	end
	default: begin
		ARValid0 = 1'b0;
	end
	endcase
end
assign ARAddr0 = (cStateInst == Inst_ARValid) ? I_addr_reg : I_addr;
always_ff @( posedge clk ) begin
    if (cStateInst == Inst_Idle && nStateInst == Inst_ARValid) begin
        I_addr_reg <= I_addr;
    end
end
/* R Channel 0 */
assign RReady0 = (cStateInst == Inst_RReady);

/* Master 0 End */

/* Master 1 */

always_ff @( posedge clk ) begin
    cStateMem <= nStateMem;
end
always_comb begin
    if (rst || lastReset) begin
        nStateMem = Data_Idle;
    end
    else begin
        case (cStateMem)
        Data_Idle: begin
            if (D_read_req && ARReady1) begin
                nStateMem = Data_RReady;
            end
            else if (D_read_req && !ARReady1) begin
                nStateMem = Data_ARValid;
            end
            else if (D_write_req) begin
                if (AWReady1 & WReady1) begin
                    nStateMem = Data_BReady;
                end
                else if (AWReady1) begin
                    nStateMem = Data_WValid;
                end
                else begin
                    nStateMem = Data_AW_WValid;
                end
            end
            else begin
                nStateMem = Data_Idle;
            end
        end
        Data_ARValid: begin
            if (ARReady1) begin
                nStateMem = Data_RReady;
            end
            else begin
                nStateMem = Data_ARValid;
            end
        end
        Data_RReady: begin
            if (RValid1 && RLast1) begin
                nStateMem = Data_Idle;
            end
			else begin
				nStateMem = Data_RReady;
			end
        end
        Data_AW_WValid: begin
            if (AWReady1 & WReady1) begin
                nStateMem = Data_BReady;
            end
            else if (AWReady1) begin
                nStateMem = Data_WValid;
            end
            else begin
                nStateMem = Data_AW_WValid;
            end
        end
        Data_WValid: begin
            nStateMem = (WReady1) ? Data_BReady : Data_WValid;            
        end
        Data_BReady: begin
            if (!BValid1) begin
                nStateMem = Data_BReady;
            end
            else begin
                nStateMem = Data_Idle;
            end
        end
        default: begin
            nStateMem = Data_Idle;
        end
        endcase
    end
end

// signal to cache
assign D_valid  = RValid1;
assign D_out = RData1;

assign D_read_req   = D_req & ~D_write;
assign D_write_req  = D_req & D_write;

assign ARAddr1 = (cStateMem == Data_Idle) ? D_addr : D_addr_reg;

always_comb begin
    if(cStateMem == Data_Idle) begin
        if(D_read_req) begin
            if(ARValid1 && ARReady1)
                D_wait = 1'b0;
            else
                D_wait = 1'b1;
        end
        else if(D_write_req) begin
            if(AWValid1 && AWReady1)
                D_wait = 1'b0;
            else
                D_wait = 1'b1;
        end
        else begin
            D_wait = 1'b0;
        end            
    end
    else
        D_wait = 1'b1;
end

always_ff @( posedge clk ) begin 
    if (cStateMem == Data_Idle && nStateMem != Data_Idle) begin
        D_addr_reg      <= D_addr;
        D_in_reg        <= D_in;
        D_type_reg      <= D_type;
        D_strobe_reg    <= D_strobe;
    end
end

always_comb begin
    if((cStateMem == Data_Idle)) begin
        D_addr_out      = D_addr;
        D_in_out        = D_in;
        D_type_out      = D_type;
        D_strobe_out    = ~D_strobe_b;
    end
    else begin
        D_addr_out      = D_addr_reg;
        D_in_out        = D_in_reg;
        D_type_out      = D_type_reg;
        D_strobe_out    = D_strobe_reg;
    end
end

/* AR Channel 1 */
assign ARId1 = 4'd0;
assign ARLen1 = D_burst? 4'd1 : 4'd0;
assign ARSize1 = 3'd3;
assign ARBurst1 = `AXI_BURST_INCR;
always_comb begin
	case (cStateMem) 
	Data_Idle: begin
		ARValid1 = D_read_req & !lastReset;
	end
	Data_ARValid: begin
		ARValid1 = 1'b1;
	end
	default: begin
		ARValid1 = 1'b0;
	end
	endcase
end
/* R Channel 1 */
assign RReady1 = (cStateMem == Data_RReady);

/* AW Channel 1 */
assign AWId1 = 4'd0;
assign AWAddr1 = D_addr_out;
assign AWLen1 = 4'd0;
assign AWSize1 = {1'b0, D_type_out[1:0]};

assign AWBurst1 = `AXI_BURST_INCR;
always_comb begin
    case (cStateMem)
    Data_Idle: begin
        AWValid1 = D_write_req;
        WValid1 = D_write_req;
    end
    Data_AW_WValid: begin
        AWValid1 = 1'b1;
        WValid1 = 1'b1; //?
    end
    Data_WValid: begin
        AWValid1 = 1'b0;
        WValid1 = 1'b1;
    end
    Data_BReady: begin
        AWValid1 = 1'b0;
        WValid1 = 1'b0;
    end
    default: begin
        AWValid1 = 1'b0;
        WValid1 = 1'b0;
    end
    endcase
end
/* W Channel 1 */
assign D_strobe = ~D_strobe_b;
assign WData1 = D_in_out;
assign WStrb1 = D_strobe_out;
assign WLast1 = WValid1;
/* B Channel 1 */
assign BReady1 = (cStateMem == Data_BReady);
/* Master 1 End */

CPU_with_cache CPU_with_cache_1(
    .clk(clk),
    .rst(rst),
    .D_out(D_out),
    .D_wait(D_wait),
    .D_valid(D_valid),  // return data is valid
    .D_req(D_req),
    .D_write(D_write),
    .D_strobe(D_strobe_b),
    .D_addr(D_addr),
    .D_in(D_in),
    .D_type(D_type),
    .D_burst(D_burst),
    .I_out(I_out),
    .I_wait(I_wait),
    .I_valid(I_valid),  // return data is valid
    .I_req(I_req),  
    .I_addr(I_addr),
    .extern_interrupt(extern_interrupt)
);

endmodule
