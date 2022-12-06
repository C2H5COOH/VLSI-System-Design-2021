`include "../../include/Control.svh"
`define INTR_STATE_BITS 3
module Intr_ctrl(
    input clk,rst,

    input [31:0]    instruction,
    output logic    pc_wfi,
    output logic    pc_mret,

    input           csr_meie,
    input           csr_mie,
    output logic    csr_intr,
    output logic    csr_intr_end,

    input           interrupt,
    input           AXI_IF_stall,
    input           AXI_MEM_stall,
    output logic    inst_invalid
);

//fsm
typedef enum logic[`INTR_STATE_BITS - 1:0] { 
    NORMAL, REC_INTR, TRAP, MRET, WFI
} FSM;
FSM state,nstate;

always_ff @(posedge clk) begin
    if(rst) state <= NORMAL;
    else    state <= nstate;
end

always_comb begin
    case(state)
        NORMAL : begin
            if(interrupt && csr_meie && csr_mie) begin //interrupt can be taken
                if(AXI_IF_stall || AXI_MEM_stall) // pc is stalling
                    nstate = REC_INTR;
                else 
                    nstate = TRAP;
            end
            else if(instruction == `WFI) begin
                    nstate = WFI;
            end
            else    nstate = NORMAL;
        end

        REC_INTR : begin
            if(AXI_IF_stall || AXI_MEM_stall) begin// wait for pc to un-stall
                nstate = REC_INTR;
            end
            else begin
                nstate = TRAP;
            end
        end

        TRAP : begin
            if(instruction == `MRET) begin
                if(AXI_IF_stall || AXI_MEM_stall) begin// pc is stalling
                    nstate = MRET;
                end
                else begin
                    nstate = NORMAL;
                end
            end
            else    nstate = TRAP;
        end

        WFI : begin
            if(interrupt && csr_meie) begin // WFI ignore global enable 
                if(AXI_IF_stall || AXI_MEM_stall) // pc is stalling
                    nstate = REC_INTR;
                else 
                    nstate = TRAP;
            end
            else nstate = WFI;
        end

        MRET : begin
            if(AXI_IF_stall || AXI_MEM_stall) begin// pc is stalling
                nstate = MRET;
            end
            else begin
                nstate = NORMAL;
            end
        end
        default : begin
            nstate = NORMAL;
        end
    endcase
end

// To pc
always_comb begin
    case(state)
        NORMAL : begin
            if(nstate == WFI) begin
                pc_wfi = 1'b1;
            end
            else begin
                pc_wfi = 1'b0;
            end
            pc_mret = 1'b0;
        end
        WFI : begin
            //pc_wfi = 1'b1;
            pc_wfi = (nstate == TRAP)? 1'b0 : 1'b1;
            pc_mret = 1'b0;
        end
        TRAP : begin
            pc_wfi = 1'b0;
            if(instruction == `MRET) begin
                pc_mret = 1'b1;
            end
            else begin
                pc_mret = 1'b0;
            end
        end
        MRET : begin
            pc_wfi = 1'b0;
            pc_mret = 1'b1;
        end
        default : begin
            pc_wfi = 1'b0;
            pc_mret = 1'b0;
        end
    endcase
end

// To CSR
always_comb begin
    case(state)
        NORMAL : begin
            if(nstate == TRAP) 
                csr_intr = 1'b1;
            else
                csr_intr = 1'b0;
                
            csr_intr_end = 1'b0;
        end
        REC_INTR : begin
            if(nstate == TRAP) 
                csr_intr = 1'b1;
            else
                csr_intr = 1'b0;
            csr_intr_end = 1'b0;
        end
        TRAP : begin
            csr_intr = 1'b0;
            if(nstate == NORMAL) begin
                csr_intr_end = 1'b1;
            end
            else csr_intr_end = 1'b0;
        end
        MRET : begin
            csr_intr = 1'b0;
            if(nstate == NORMAL)
                csr_intr_end = 1'b1;
            else 
                csr_intr_end = 1'b0;
        end
        WFI : begin
            if(nstate == TRAP) // Condition of nstate==trap is slightly different from REC_INTR
                csr_intr = 1'b1;
            else
                csr_intr = 1'b0;

            csr_intr_end = 1'b0;
        end
        default : begin
            csr_intr = 1'b0;
            csr_intr_end = 1'b0;
        end
    endcase
end

// Block the instruction after mret
always_ff @(posedge clk) begin
    if(rst) inst_invalid <= 1'b0;
    else begin
        if( (state == TRAP) && (nstate == NORMAL) ) begin
            inst_invalid <= 1'b1; // block the instruction after mret
        end
        else if( (state == MRET) && (nstate == NORMAL) ) begin
            inst_invalid <= 1'b1; // block the instruction after mret
        end
        else inst_invalid <= 1'b0;
    end
end



endmodule