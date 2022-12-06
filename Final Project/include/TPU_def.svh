`ifndef SYSTOLIC_DEF_SVH
`define SYSTOLIC_DEF_SVH
`include "AXI_def.svh"
/* MAC */
`define IFM_PER_BYTE_BIT        8
`define MAC_IN_BIT              9
`define MAC_OUT_BIT             24
`define MAC_MAX                 24'h7fffff
`define MAC_MIN                 24'h800000

/* Systolic array */
`define SYS_HEIGHT              9
`define SYS_WIDTH               8

/* TPU control */
`define TPU_INPUT_CTRL_BIT      20
`define TPU_SYS_CTRL_BIT        25

/* TPU input control */
`define TPU_INPUT_CTRL_OFFSET   `AXI_ADDR_BITS'd0
`define INPUT_CTRL_MODE_BIT     3
`define INPUT_SRAM_ID_BIT       1
`define INPUT_CTRL_DEPTH_BIT    10
`define INPUT_CTRL_WIDTH_BIT    4
`define INPUT_IFM_WIDTH_BIT     6
`define INPUT_IFM_HEIGHT_BIT    6
`define INPUT_PADDING_BIT       4
`define INPUT_ENQ_OFFSET_BIT    4
`define INPUT_DEQ_OFFSET_BIT    6
`define INPUT_DEQ_OFFSET_MAX    (`INPUT_DEQ_OFFSET_BIT'd58)
`define INPUT_DEQ_OFFSET_MIN    (`INPUT_DEQ_OFFSET_BIT'd0)
`define INPUT_ROW_OFFSET_BIT    6
`define INPUT_ROW_OFFSET_MAX    (`INPUT_ROW_OFFSET_BIT'd58)
`define INPUT_ROW_OFFSET_MIN    (`INPUT_ROW_OFFSET_BIT'd0)
`define INPUT_ROW_INDEX_BIT     2

/* TPU systolic/W/OFM control */
`define TPU_SYS_CTRL_OFFSET     `AXI_ADDR_BITS'd4
`define SYS_CTRL_WIDTH_BIT      3
`define SYS_CTRL_DEPTH_BIT      11
`define SYS_CTRL_COMMAND_BIT    5
`define SYS_CTRL_KERNEL_BIT     7
`define SYS_COUNTER_BIT         11
`define SYS_FIRST_ARRIVE        18

`define TPU_DATA_OFFSET         `AXI_ADDR_BITS'd8

/* TPU input data */
`define NUM_INPUT_REG_PER_ROW   (61)
`define NUM_INPUT_REG_ROW       (3)
`define IFM_SRAM_ADDR_BIT       10
`define IFM_SRAM_ADDR_SHORT_BIT 7
`define IFM_SRAM_ADDR_MID_BIT   8
`define IFM0_INDEX_BIT          3
`define Q_INDEX_BIT             7
/* TPU weight data */
`define W_SRAM_ADDR_BIT         11

/* TPU output data */
`define OFM_SRAM_ADDR_BIT       10
`define Q_REG_BIT               24
`define OFM_QED_REG(x)          IFM_InputReg[0][(x)]
`define Q_THRES_REG(x)          IFM_InputReg[1][(x)]
`define NUM_Q_SPLIT             8

/* TPU bias data */
`define NUM_BIAS_REG            8

/* Input Mode Enumeration */
typedef enum logic [`INPUT_CTRL_MODE_BIT-1:0] { 
    INPUT_MODE_NO_CONV,
    INPUT_MODE_CONV2D_S1,
    INPUT_MODE_CONV2D_S2,
    INPUT_Q_THRES,
    INPUT_MODE_IDLE
} InputModeEnum;

/* Command Enumeration */
typedef enum logic [`SYS_CTRL_COMMAND_BIT-1:0] { 
    IDLE=0,
    CONSUME_IFM_SRAM0_BIAS,
    CONSUME_IFM_SRAM0_ACC,
    CONSUME_IFM_SRAM1_BIAS,
    CONSUME_IFM_SRAM1_ACC,
    WRITE_BIAS,
    WRITE_W,
    READ_OFM_ROW_RAW,
    READ_OFM_COL_RAW,
    READ_OFM_ROW_QED,
    READ_OFM_COL_QED
} CommandEnum;

/* Systolic array width enumeration */
typedef enum logic [`SYS_CTRL_WIDTH_BIT-1:0] {
    WIDTH_1 = 0,
    WIDTH_2,
    WIDTH_3,
    WIDTH_4,
    WIDTH_5,
    WIDTH_6,
    WIDTH_7,
    WIDTH_8
} SysWidthEnum;

/* Systolic array AXI state enumeration */
typedef enum logic[1:0] {
    AXI_IDLE,
    AXI_WRITE,
    AXI_READ,
    AXI_R_PENDING
} TPU_AXI_State;

/* OFM reading order enumeration */
typedef enum logic {
    ROW,
    COL
} ROW_OR_COL;

/* Quantization state enumeration */
typedef enum logic[3:0] { 
    QIDLE,
    INPUT_2,
    INPUT_4,
    INPUT_6,
    INPUT_8,    //SORT1_A
    SORT_1_D,
    SORT_2_A,
    SORT_2_D,
    SORT_3_A,
    SORT_3_D,
    SORT_4_A,
    SORT_4_D,
    QOUTPUT,
    QADDR,
    QTMP_LATCH_DATA
} Q_STATE;
`endif