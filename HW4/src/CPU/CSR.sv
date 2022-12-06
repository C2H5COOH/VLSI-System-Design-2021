`include "../../include/Control.svh"
 
`define CSR_NUM 9
`define STA_MPIE mstatus[7]
`define STA_MIE mstatus[3]
`define STA_MPP mstatus[12:11]

module CSR(
    input clk,rst,
    input [11:0]            read_addr,write_addr,
    input [31:0]            write_data,
    input                   write_en,
    input                   read,
    output logic [31:0]     read_data,

    input                   intr,intr_end,
    input [31:0]            pc_store,
    output logic [31:0]     csr_pc,

    output csr_meie, csr_mie,

    input inst_stall
);

    //decode
    typedef enum logic[`CSR_NUM - 1:0] { 
		MSTATUS, MIE, MTVEC, MEPC, MIP, MCYCLE, MCYCLEH, MINSTRET, MINSTRETH, INVALID
    } ADDR_DECODE;
	ADDR_DECODE read_decode, write_decode;

    //read address decode
    always_comb begin
        case(read_addr)
            12'h300 : read_decode = MSTATUS;
            12'h304 : read_decode = MIE;
            12'h305 : read_decode = MTVEC;
            12'h341 : read_decode = MEPC;
            12'h344 : read_decode = MIP;
            12'hb00 : read_decode = MCYCLE;
            12'hb02 : read_decode = MINSTRET;
            12'hb80 : read_decode = MCYCLEH;
            12'hb82 : read_decode = MINSTRETH;
            default : read_decode = INVALID;
        endcase
    end

    always_comb begin
        case(write_addr)
            12'h300 : write_decode = MSTATUS;
            12'h304 : write_decode = MIE;
            12'h305 : write_decode = MTVEC;
            12'h341 : write_decode = MEPC;
            12'h344 : write_decode = MIP;
            12'hb00 : write_decode = MCYCLE;
            12'hb02 : write_decode = MINSTRET;
            12'hb80 : write_decode = MCYCLEH;
            12'hb82 : write_decode = MINSTRETH;
            default : write_decode = INVALID;
        endcase
    end


    //CSR access
    logic [31:0] mstatus, mie, mtvec, mepc, mip, mcycle, minstret, mcycleh, minstreth;
    assign csr_meie = mie[11];
    assign csr_mie = `STA_MIE;

    always_comb begin
        if(read) begin
            // Read_invalid : assert(decode != INVALID);
            case(read_decode)
               MSTATUS :    read_data = mstatus;
               MIE :        read_data = mie;
               MTVEC :      read_data = mtvec;
               MEPC :       read_data = mepc;
               MIP :        read_data = mip;
               MCYCLE :     read_data = mcycle;
               MCYCLEH :    read_data = mcycleh;
               MINSTRET :   read_data = minstret;
               MINSTRETH :  read_data = minstreth;
               INVALID :    read_data = 32'hffff_ffff;
               default :    read_data = 32'hffff_ffff;
            endcase
        end
        else read_data = 32'hffff_ffff;
    end

    assign mip = {20'b0, intr, 11'b0};
    assign mtvec = 32'h0001_0000;
    always_comb begin
        csr_pc = (intr)? mtvec : 
                (intr_end)? mepc : 32'hffff_ffff;
    end

    //instruction write
    always_ff @(posedge clk) begin
        if(rst) begin
            mstatus     <= 32'b0;
            mie         <= 32'b0;
            mepc        <= 32'b0;
        end
        else begin
            if(write_en) begin
                // Write_invalid : assert ((write_decode == MSTATUS) || (write_decode == MIE) || (write_decode == MEPC) );
                // Write_during_interrupt : assert (intr!);

                case(write_decode)
                    MSTATUS : begin 
                        `STA_MIE <= write_data[3];//MIE
                        `STA_MPIE <= write_data[7];//MPIE
                        `STA_MPP <= write_data[12:11];//MPP
                    end
                    MIE     : mie[11] <= write_data[11];
                    MEPC    : mepc <= write_data;
                    default : ;
                endcase
            end
            else begin
                unique if(intr) begin
                    `STA_MPIE    <= `STA_MIE;
                    `STA_MIE     <= 1'b0;
                    `STA_MPP     <= 2'b11;
                    mepc <= pc_store;
                end
                else if(intr_end) begin
                    `STA_MPIE    <= 1'b1;
                    `STA_MIE     <= `STA_MPIE;
                    `STA_MPP     <= 2'b11;
                    mepc <= pc_store;
                end
                else begin
                    `STA_MPIE    <= `STA_MPIE;
                    `STA_MIE     <= `STA_MIE;
                    `STA_MPP     <= `STA_MPP;
                    mepc <= mepc;
                end
            end
        end
    end

    //cycle
    always_ff @(posedge clk) begin
        if(rst) begin
            mcycle <= 32'b0;
            mcycleh <= 32'b0;
        end
        else begin
            mcycle <= mcycle + 1;
            mcycleh <= (mcycle == 32'hffff_ffff)? mcycleh+1 : mcycleh;
        end
    end

    //instruction
    always_ff @(posedge clk) begin
        if(rst) begin
            minstret <= 32'b0;
            minstreth <= 32'b0;
        end
        else begin
            if(!inst_stall)begin
                minstret <= minstret + 1;
                minstreth <= (minstret == 32'hffff_ffff)? minstreth+1 : minstreth;
            end
            else begin
                minstret <= minstret;
                minstreth <= minstreth;
            end
        end
    end

endmodule