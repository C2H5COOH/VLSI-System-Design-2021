`include "TPU_def.svh"
module Weight_wrapper (
    input                                   CK,
    input [`W_SRAM_ADDR_BIT-1:0]            A,
    input [`IFM_PER_BYTE_BIT-1:0]           DI  [0:`SYS_WIDTH-1],
    input [`SYS_WIDTH-1:0]                  WEB,
    input                                   OE,
    input                                   CS,
    output logic [`IFM_PER_BYTE_BIT-1:0]    DO  [0:`SYS_WIDTH-1]
);
SUMA180_1152X8X8BM1 iSRAM8x8 (
    .A0(A[0]),
    .A1(A[1]),
    .A2(A[2]),
    .A3(A[3]),
    .A4(A[4]),
    .A5(A[5]),
    .A6(A[6]),
    .A7(A[7]),
    .A8(A[8]),
    .A9(A[9]),
    .A10(A[10]),
    .DO0(DO[0][0]),
    .DO1(DO[0][1]),
    .DO2(DO[0][2]),
    .DO3(DO[0][3]),
    .DO4(DO[0][4]),
    .DO5(DO[0][5]),
    .DO6(DO[0][6]),
    .DO7(DO[0][7]),
    .DO8(DO[1][0]),
    .DO9(DO[1][1]),
    .DO10(DO[1][2]),
    .DO11(DO[1][3]),
    .DO12(DO[1][4]),
    .DO13(DO[1][5]),
    .DO14(DO[1][6]),
    .DO15(DO[1][7]),
    .DO16(DO[2][0]),
    .DO17(DO[2][1]),
    .DO18(DO[2][2]),
    .DO19(DO[2][3]),
    .DO20(DO[2][4]),
    .DO21(DO[2][5]),
    .DO22(DO[2][6]),
    .DO23(DO[2][7]),
    .DO24(DO[3][0]),
    .DO25(DO[3][1]),
    .DO26(DO[3][2]),
    .DO27(DO[3][3]),
    .DO28(DO[3][4]),
    .DO29(DO[3][5]),
    .DO30(DO[3][6]),
    .DO31(DO[3][7]),
    .DO32(DO[4][0]),
    .DO33(DO[4][1]),
    .DO34(DO[4][2]),
    .DO35(DO[4][3]),
    .DO36(DO[4][4]),
    .DO37(DO[4][5]),
    .DO38(DO[4][6]),
    .DO39(DO[4][7]),
    .DO40(DO[5][0]),
    .DO41(DO[5][1]),
    .DO42(DO[5][2]),
    .DO43(DO[5][3]),
    .DO44(DO[5][4]),
    .DO45(DO[5][5]),
    .DO46(DO[5][6]),
    .DO47(DO[5][7]),
    .DO48(DO[6][0]),
    .DO49(DO[6][1]),
    .DO50(DO[6][2]),
    .DO51(DO[6][3]),
    .DO52(DO[6][4]),
    .DO53(DO[6][5]),
    .DO54(DO[6][6]),
    .DO55(DO[6][7]),
    .DO56(DO[7][0]),
    .DO57(DO[7][1]),
    .DO58(DO[7][2]),
    .DO59(DO[7][3]),
    .DO60(DO[7][4]),
    .DO61(DO[7][5]),
    .DO62(DO[7][6]),
    .DO63(DO[7][7]),
    .DI0(DI[0][0]),
    .DI1(DI[0][1]),
    .DI2(DI[0][2]),
    .DI3(DI[0][3]),
    .DI4(DI[0][4]),
    .DI5(DI[0][5]),
    .DI6(DI[0][6]),
    .DI7(DI[0][7]),
    .DI8(DI[1][0]),
    .DI9(DI[1][1]),
    .DI10(DI[1][2]),
    .DI11(DI[1][3]),
    .DI12(DI[1][4]),
    .DI13(DI[1][5]),
    .DI14(DI[1][6]),
    .DI15(DI[1][7]),
    .DI16(DI[2][0]),
    .DI17(DI[2][1]),
    .DI18(DI[2][2]),
    .DI19(DI[2][3]),
    .DI20(DI[2][4]),
    .DI21(DI[2][5]),
    .DI22(DI[2][6]),
    .DI23(DI[2][7]),
    .DI24(DI[3][0]),
    .DI25(DI[3][1]),
    .DI26(DI[3][2]),
    .DI27(DI[3][3]),
    .DI28(DI[3][4]),
    .DI29(DI[3][5]),
    .DI30(DI[3][6]),
    .DI31(DI[3][7]),
    .DI32(DI[4][0]),
    .DI33(DI[4][1]),
    .DI34(DI[4][2]),
    .DI35(DI[4][3]),
    .DI36(DI[4][4]),
    .DI37(DI[4][5]),
    .DI38(DI[4][6]),
    .DI39(DI[4][7]),
    .DI40(DI[5][0]),
    .DI41(DI[5][1]),
    .DI42(DI[5][2]),
    .DI43(DI[5][3]),
    .DI44(DI[5][4]),
    .DI45(DI[5][5]),
    .DI46(DI[5][6]),
    .DI47(DI[5][7]),
    .DI48(DI[6][0]),
    .DI49(DI[6][1]),
    .DI50(DI[6][2]),
    .DI51(DI[6][3]),
    .DI52(DI[6][4]),
    .DI53(DI[6][5]),
    .DI54(DI[6][6]),
    .DI55(DI[6][7]),
    .DI56(DI[7][0]),
    .DI57(DI[7][1]),
    .DI58(DI[7][2]),
    .DI59(DI[7][3]),
    .DI60(DI[7][4]),
    .DI61(DI[7][5]),
    .DI62(DI[7][6]),
    .DI63(DI[7][7]),
    .CK(CK),
    .WEB0(WEB[0]),
    .WEB1(WEB[1]),
    .WEB2(WEB[2]),
    .WEB3(WEB[3]),
    .WEB4(WEB[4]),
    .WEB5(WEB[5]),
    .WEB6(WEB[6]),
    .WEB7(WEB[7]),
    .OE(OE),
    .CS(CS)
);
endmodule