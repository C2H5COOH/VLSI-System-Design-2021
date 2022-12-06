// `include "PC.sv"
`include "CPU/PC.sv"

module IF (
    input                   clk,rst,

    input [31:0]            EXE_jumpBranchAddr,
    input                   EXE_jumpBranch,
    input                   ID_hazardStall,

    output logic [31:0]     instruction_reg,
    output logic [31:0]     pc_reg,

    output logic [31:0]     IM_addr,
    output logic            IM_read,
    input  [31:0]           IM_instruction,

    input                   AXI_IF_stall,
    input                   AXI_MEM_stall
);

logic [31:0] pcOut;
logic [31:0] pcAdd4;
assign pcAdd4 = pcOut + 4;

logic jumpBranch_reg;
logic [31:0] jb_addr_reg;

logic [31:0]    pc_jb_addr;
logic           pc_jb;


PC pc(
    .clk(clk), 
    .rst(rst),

    .pcAdd4(pcAdd4),
    .jumpBranchAddr(pc_jb_addr),

    .pcOut(pcOut),

    .hazard_stall(ID_hazardStall),
    .AXI_IF_stall(AXI_IF_stall),
    .jump_branch(pc_jb),
    .AXI_MEM_stall(AXI_MEM_stall)

);

always_comb begin
    if(AXI_IF_stall) begin
        pc_jb       = 1'b0;
        pc_jb_addr  = 32'b0;
    end
    else begin
        if(EXE_jumpBranch) begin
            pc_jb       = EXE_jumpBranch;
            pc_jb_addr  = EXE_jumpBranchAddr;
        end
        else if(jumpBranch_reg) begin
            pc_jb       = jumpBranch_reg;
            pc_jb_addr  = jb_addr_reg;
        end
        else begin
            pc_jb       = 1'b0;
            pc_jb_addr  = 32'b0;
        end
    end
end
/*always_comb begin
    if(cache_allow) begin
        pc_jb       = EXE_jumpBranch;
        pc_jb_addr  = EXE_jumpBranchAddr;
    end
    else begin
        pc_jb       = jumpBranch_reg;
        pc_jb_addr  = jb_addr_reg;
    end
end*/

always_ff @(posedge clk) begin
    if(rst) begin
        jumpBranch_reg  <= 1'b0;
        jb_addr_reg     <= 32'b0;
    end
    else begin
        if(AXI_IF_stall) begin
            if(EXE_jumpBranch) begin
                jumpBranch_reg <= 1'b1;
                jb_addr_reg <= EXE_jumpBranchAddr;
            end 
            else begin
                jumpBranch_reg <= jumpBranch_reg;
                jb_addr_reg <= jb_addr_reg;
            end
        end
        else begin
            jumpBranch_reg <= 1'b0;
            jb_addr_reg <= 32'b0;
        end
    end
end
/*always_ff @(posedge clk) begin
    if(rst) begin
        jumpBranch_reg  <= 1'b0;
        jb_addr_reg     <= 32'b0;
    end
    else begin
        if( (~cache_allow) ) begin
            if(EXE_jumpBranch) begin
                jumpBranch_reg <= 1'b1;
                jb_addr_reg <= EXE_jumpBranchAddr;
            end
            else begin
                jumpBranch_reg  <= jumpBranch_reg;
                jb_addr_reg     <= jb_addr_reg;
            end
        end
        else begin
            jumpBranch_reg  <= 1'b0;
            jb_addr_reg     <= 32'b0;
        end
    end
    
end*/


//register suppose to be flushed when hazard or jump or branch
//since pc needs extra cycle to load new address
//instruction goes directly through register, since IM already needs a cycle to load

logic init;
always_ff @(posedge clk) begin
    if(rst) init <= 1'b1;
    else init <= 1'b0 ;
end

//IM_addr
always_comb begin
    if(EXE_jumpBranch) 
        IM_addr = EXE_jumpBranchAddr;
    else if (jumpBranch_reg)
        IM_addr = jb_addr_reg;
    else                
        IM_addr = pcOut;
end
/*always_comb begin
    if( (cache_allow) && EXE_jumpBranch) IM_addr = EXE_jumpBranchAddr;
    else begin 
        IM_addr = pcOut;
    end
end*/

always_ff @(posedge clk) begin
    if(rst) IM_read <= 1'b0;
    else    IM_read <= 1'b1;
end

/*always_ff @(posedge clk) begin
    if(AXI_MEM_stall || ID_hazardStall)begin
        pc_reg          <= pc_reg;
        instruction_reg <= instruction_reg;
    end
    else if(rst || AXI_IF_stall || init || jumpBranch_reg || EXE_jumpBranch)begin
        pc_reg          <= 32'b0;
        instruction_reg <= 32'b0;
    end
    else begin
        pc_reg          <= pcOut;
        instruction_reg <= IM_instruction;
    end
end*/

always_ff @(posedge clk) begin
    if(rst) begin
        pc_reg          <= 32'b0;
        instruction_reg <= 32'b0;
    end
    else begin
        if(AXI_MEM_stall || ID_hazardStall)begin
            pc_reg          <= pc_reg;
            instruction_reg <= instruction_reg;
        end
        else if(AXI_IF_stall || init || jumpBranch_reg || EXE_jumpBranch)begin
            pc_reg          <= 32'b0;
            instruction_reg <= 32'b0;
        end
        else begin
            pc_reg          <= pcOut;
            instruction_reg <= IM_instruction;
        end
    end
    
end
    
endmodule 
