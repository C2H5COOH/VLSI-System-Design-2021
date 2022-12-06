# VSD_2021

Design of the TPU co-processor and the verification platform.

## Address Table
| Name   | Number  | Start Address | End Address |
| ------ | ------- | ------------- | ----------- |
| ROM    | Slave 0 | 0x0000_0000   | 0x0000_1FFF |
| IM     | Slave 1 | 0x0001_0000   | 0x0001_FFFF |
| DM     | Slave 2 | 0x0002_0000   | 0x0002_FFFF |
| Sensor | Slave 3 | 0x1000_0000   | 0x1000_03FF |
| DRAM   | Slave 4 | 0x2000_0000   | 0x21FF_FFFF |
| DMA    | Slave 5 | 0x3000_0000   | 0x3000_0FFF |
| TPU    | Slave 6 | 0x3000_1000   | 0x3000_100F |
| PLIC   | Slave 7 | 0x0004_0000   | 0x0004_3FFF |

## DRAM Address Table
|   Name      | Start Address | End Address |
| ------      | ------------- | ----------- |
|   Inst      | 0x2000_0000   | 0x203f_FFFF |
|   IFM       | 0x2040_0000   | 0x2042_FFFF |
|   OFM       | 0x2043_0000   | 0x205F_FFFF |
|   weight    | 0x2060_0000   | 0x206F_FFFF |
|   bias      | 0x2070_0000   | 0x2070_FFFF |
| threshhold  | 0x2071_0000   | 0x2071_FFFF |
|   data      | 0x2072_0000   | 0x20FF_FFFF |
|   Sensor    | 0x2100_0000   | 0x21FF_FFFF |

## DMA Regulations
> Whenever you want to use DMA to transfer data, you need to set following parameters:
* ***Clear*** Interrupt
  > Status register address is **0x000**.
  > Clear interrupt with **Non-zero** number.
* ***Source*** Address
  > Status register address is **0x100**.
  > Support both aligned address & unaligned address.
* ***Target*** Address
  > Status register address is **0x200**.
  > Only support aligned address.
* Transfer ***Mode***
  > Status register address is **0x300**.
  > Four modes support:
  1. Source Address Fix & Target Address Fix (S_F_T_F)
  2. Source Address Fix & Target Address Accumulate (S_F_T_A)
  3. Source Address Accumulate & Target Address Fix (S_A_T_F)
  4. Source Address Accumulate & Target Address Accumulate (S_A_T_A) 
* ***Times*** of Discontinuous Transfer
  > Status register address is **0x400**.
  > Must be a **Non-zero** number.
* ***Stride*** of Address for Discontinuous Transfer
  > Status register address is **0x500**.
  > Must be a **Non-zero** number.
* ***Length*** of **ONE** Continuous Transfer
  > Status register address is **0x600**.
  > Must be a **Non-zero** number.

## Hardware 
### TPU Wrapper to TPU
```
                  |             |writeInputControlEn->
                  |             |nInputControl[31:0]->
                  |             |writeSysControlEn->
                  |             |nSysControl[31:0]->
<= AXI Bus Slave=>| AXI Wrapper |writeDataEn[7:0]->
                  |             |DI[63:0]->
                  |             |readDataEn->
                  |             |<-DO[63:0]
                  |             |<-readWriteDone
```

### TPU Configuration
* Systolic Array: 72 sets of 8-16-8 MACs
* Input SRAMs: 2\*1032(words) x 9(bytes/word) x 8(bits/byte)
* Weight SRAM: 1152(words) x 8(bytes/word) x 8(bits/byte)
* Output SRAM: 2\*512(words) x 8(bytes/word) x 16(bits/byte)
* Accumulator: 16 sets of 16 bits adder
  | Channel       | t0           | t1               | t2           | t3               |
  | ------------- | ------------ | ---------------- | ------------ | ---------------- |
  | Address       | Read A0      | Write A0         | Read A1      | Write A1         |
  | Data In       |              | DataOut + Result |              | DataOut + Result |
  | Data Out      |              | [A0]             |              | [A1]             |
  | Accumulator   |              | [A0] + Result    |              | [A1] + Result    |
  | Sytolic array | Result [0:7] | Result [8:15]    | Result [0:7] | Result [8:15]    |

* Activation: 8 sets of ReLU module

* Input Expension: 
  * 1-to-9 expension on stride-1-3x3-convolution
  * 1-to-4 expension on stride-2-3x3-convolution
  * Using (2\*sqrt(inputDepth)+1)\*3 as input temporary register to store first three row.

* Q-DeQer:
  * 8 sets of 8-to-8 LUT to make quantization/requantization conversion

* Interconnection to Wrapper/Bus:
  * 64 bits/cycle
  * **Weight must be accessed in 8-byte aligned**
  * **Completion of bias writing would not trigger interrupt**
  * **Input can be access in unaligned**

* Address Mapping (0x0\~0xd470):  
  TPU would suppose input data as double word addressing except for control register.  
  For input SRAM, since it has dependency among input data, transmission from lower address to higher address is expected.
  * Control Register (0x0\~0x7):  
    Input Control (0x0\~0x3):  
    |          | 17:14             | 13:4              | 3             | 2:0 |
    | -------- | ----------------- | ----------------- | ------------- | --- |
    | Reserved | Input Width [3:0] | Input Depth [9:0] | Input SRAM Id | 00  |

    |          | 19:16              | 15:10            | 9:4             | 3             | 2:0   |
    | -------- | ------------------ | ---------------- | --------------- | ------------- | ----- |
    | Reserved | Padding Bits [3:0] | IFM Height [5:0] | IFM Width [5:0] | Input SRAM Id | 01/10 |

    * Input Mode  
      3 bit  
      | Value  | Representation                         |
      | ------ | -------------------------------------- |
      | 3'b000 | Input without convolution              |
      | 3'b001 | Input with convolution 2d 3x3 stride 1 |
      | 3'b010 | Input with convolution 2d 3x3 stride 2 |
      | 3'b011 | Input quantization thresholds          |
      | 3'b100 | Idle                                   |

    * Input SRAM Id  
      1 bit  
      Select which IFM SRAM to write to.

    * Input Depth  
      12 bits  
      Indicate how many columns of input SRAM would be filled.

    * Input Width  
      4 bits  
      Indicate how many rows of input SRAM would be filled.  

    * IFM Width  
      6 bits  
      When using 3x3 convolution expansion, configure width of feature map.

    * IFM Height  
      6 bits  
      When using 3x3 convolution expansion, configure height of feature map.

    * Padding Bits  
      4 bits  
      [Upper|Lower|Left|Right] padding for 4 directions.

    Systolic Control (0x4~0x7):  
    | 31:25    | 24:22           | 21:12           | 11:5             | 4:0          |
    | -------- | --------------- | --------------- | ---------------- | ------------ |
    | Reserved | SYS Width [2:0] | SYS Depth [9:0] | SYS Kernel [6:0] | Command[4:0] |

    * SYS Width  
      3 bits  
      Indicate how many columns of OFM or weight SRAM would be read/written when reading/writing OFM or weight SRAM. If value of this register is n, then n + 1 output SRAM would be written.

    * SYS Depth  
      10 bits  
      Indicate how many rows of output SRAM would be requested to be read/written.

    * SYS Kernel  
      7 bits  
      Indicate which weight to be loaded before consuming input, or indicate the number of kernels would be transmitted from external.  
      If the value is n, then nth kernel should be loaded when consuming, or n+1 kernels would be written.

    * Command  
      5 bits  
      | Value | Representation                                      |
      | ----- | --------------------------------------------------- |
      | 5'd0  | Idle                                                |
      | 5'd1  | Consume IFM SRAM 0                                  |
      | 5'd2  | Consume IFM SRAM 0 with previous value in OFM SRAM  |
      | 5'd3  | Consume IFM SRAM 1                                  |
      | 5'd4  | Consume IFM SRAM 1 with previous value in OFM SRAM  |
      | 5'd5  | Write bias for later 4 beats of 4 bytes             |
      | 5'd6  | Write weight for **sysKernel+1** kernels (72 bytes) |
      | 5'd7  | Read raw OFM in row major (HWC) order               |
      | 5'd8  | Read raw OFM in column major (CHW) order            |
      | 5'd9  | Read quantized OFM in row major (HWC) order         |
      | 5'd10 | Read quantized OFM in column major (CHW) order      |

  * Data Slot(0x8~0xf):   
    When AXI slave is at writing state, this segment is for external source to write 8-byte data which is for input/weight SRAM or bias/quantization registers.  
    When AXI slave is at reading state, this segment is to response data to external drain.
### PLIC
- in C code, need to set interrupt enable bits  
addr on bus：0x4000_2000  
enable sensor：write 1 to it (001)  
enable DMA：write 2 to it (010)  
enable TPU：write 4 to it (100) 
- isr.S  
copy sim/plic_dma_boot/isr.S to your folder  
- C code example:  
```=C
volatile unsigned* plic_en = (unsigned *) 0x40002000;  
*plic_en = 2; // enable DMA interrupt  
```
   