# 一、需求分析

## 指令一：add

### 1.从GRF中读取rs,rt
- 操作：(rs)->RegRead1, (rt)->RegRead2
### 2.rs与rt通过ALU相加
- 操作：RegRead1->ALUIn1, RegRead2->ALUIn2, ALUIn1+ALUIn2->ALURes
### 3. 将结果写入rd
- 操作：rd->RegAddr, ALURes->RegData

## 指令二：sub

### 1.从GRF中读取rs,rt
- 操作：(rs)->RegRead1, (rt)->RegRead2
### 2.rs与rt通过ALU相减
- 操作：RegRead1->ALUIn1, RegRead2->ALUIn2, ALUIn1-ALUIn2->ALURes
### 3. 将结果写入rd
- 操作：rd->RegAddr, ALURes->RegData

## 指令三：ori

### 1.从GRF中读取rs,rt
- 操作：(rs)->RegRead1,(rt)->RegRead2
### 2.imm进行无符号拓展
- 操作：{16{0},imm}->extend
### 3.rs和imm通过ALU取或
- 操作：RegRead1->ALUIn1, extend->ALUIn2, ALUIn1|ALUIn2->ALURes
### 4.将结果写入rt
- 操作：rd->RegAddr, ALURes->RegData

## 指令四：lw

### 1.从GRF中读取base,rt
- 操作：(base)->RegRead1, (rt)->RegRead2
### 2.offest进行有符号拓展
- 操作：{16{offset[15]},offset}->extend
### 3.base和offest通过ALU相加
- 操作：RegRead1->ALUIn1, extend->ALUIn2, ALUIn1+ALUIn2->ALURes
### 4.将主存结果写入rt
- 操作：ALURes->MemAddr, rt->RegAddr, MemRead->RegData

## 指令五：sw

### 1.从GRF中读取base,rt
- 操作：(base)->RegRead1, (rt)->RegRead2
### 2.offest进行有符号拓展
- 操作：{16{offset[15]},offset}->extend
### 3.base和offest通过ALU相加
- 操作：RegRead1->ALUIn1, extend->ALUIn2, ALUIn1+ALUIn2->ALURes
### 4.将rt写入主存
- 操作：ALURes->MemAddr, RegRead2->MemData

## 指令六：beq

### 1.从GRF中读取rs,rt
- 操作：(rs)->RegRead1,(rt)->RegRead2
### 2.offest进行有符号拓展
- 操作：{16{offset[15]},offset}->extend
### 3.rs和rt通过ALU比较
- 操作：RegRead1->ALUIn1, RegRead2->ALUIn2, ALUIn1==ALUIn2->ALURes
### 4.修改pc值跳转
- 操作：pc+4+extend<<2->pc

## 指令七：lui

### 1.imm进行有符号拓展
- 操作：{16{imm[15]},imm}->extend
### 2.imm通过ALU加载到高位
- 操作：extend->ALUIn2, ALUIn2<<16->ALURes
### 3.将结果写入rt
- 操作：rt->RegAddr, ALURes->RegData

## 指令八：jal

### 1.index进行无符号转换
- 操作：{6{0},index}<<2->jump
### 2.将pc写入31号寄存器
- 操作：31->RegAddr, pc+4->RegData
### 3.修改pc值跳转
- 操作：jump->pc

## 指令九：jr

### 1.从GRF中读取rs
- 操作：(rs)->RegRead1
### 2.修改pc值跳转
- 操作：RegRead1->pc

# 二、控制设计

## 控制信号含义：

| 参数 | 含义 |
| --- | --- |
| RegWrite | 决定是否要写入寄存器，0 为否，1 为是 |
| RegAddrOp[1:0] | 决定写入寄存器的地址，0 为 rt，1 为 rd，2 为 31，3 为新指令 |
| RegDataOp[1:0] | 决定写入寄存器的内容，0 为 ALU 计算结果，1 为主存读取结果，2 为 PC + 4，3 为新指令  |
| MemWrite | 决定是否要写入主存，0 为否，1 为是 |
| MemAddrOp | 决定写入主存的地址，0 为 ALU 计算结果，1 为新指令  |
| MemDataOp | 决定写入主存的内容，0 为 寄存器 rt 的值，1 为新指令  |
| ALUIn1Op | 决定进入 ALU 的第一个数据，0 为寄存器 rs 的值，1 为新指令  |
| ALUIn2Op[1:0] | 决定进入 ALU 的第二个数据，0 为寄存器 rt 的值，1 为拓展立即数，2 为新指令 |
| PCOp[2:0] | 决定下一周期 PC 值，0 为 PC + 4，1 为 PC + 4 + offset \* 4，2 为 index * 4，3 为寄存器 rs 的值，4 为新指令 |
| ExtOp[1:0] | 决定立即数扩展方式，0 为符号拓展，1 为 0 拓展，2 为新指令  |
| ALUOp[2:0] | 决定 ALU 进行的运算，0 为加，1 为减，2 为或，3 为加载到高位，4 为有符号数比较，5 为无符号数比较，6 为新指令  |

## 指令对应的控制信号：

| 指令 | RegWrite | RegAddrOp[1:0] | RegDataOp[1:0] | MemWrite | MemAddrOp | MemDataOp |
| --- | --- | --- | --- | --- | --- | --- |
| add | 1 | 01 | 00 | 0 | 0 | 0 |
| sub | 1 | 01 | 00 | 0 | 0 | 0 |
| ori | 1 | 00 | 00 | 0 | 0 | 0 |
| lw  | 1 | 00 | 01 | 0 | 0 | 0 |
| sw  | 0 | 00 | 00 | 1 | 0 | 0 |
| beq | 0 | 00 | 00 | 0 | 0 | 0 |
| lui | 1 | 00 | 00 | 0 | 0 | 0 |
| jal | 1 | 10 | 10 | 0 | 0 | 0 |
| jr  | 0 | 00 | 00 | 0 | 0 | 0 |
| new | 0 | 11 | 11 | 0 | 1 | 1 |

| 指令 | ALU1InOp | ALU2InOp[1:0] | PCOp[2:0] | ExtOp[1:0] | ALUOp[2:0] |
| --- | --- | --- | --- | --- | --- |
| add | 0 | 00 |000|00|000|
| sub | 0 | 00 |000|00|001|
| ori | 0 | 01 |000|01|010|
| lw  | 0 | 01 |000|00|000|
| sw  | 0 | 01 |000|00|000|
| beq | 0 | 00 |001|00|100|
| lui | 0 | 01 |000|00|011|
| jal | 0 | 00 |010|00|000|
| jr  | 0 | 00 |011|00|000|
| new | 1 | 10 |100|10|110|

# 三、模块设计

## 模块一：GRF

- 功能同 P0 第三题 GRF


## 模块二：ALU

- ALUOp 决定 ALU 进行的运算，0 为加，1 为减，2 为或，3 为加载到高位，4 为判断是否相等

## 模块三：IFU

- 每个时钟周期上升沿将pcNext赋值给pc
- 将pc的值减去初值0x00003000，作为ROM读取的地址addr
- 每个时钟周期上升沿从ROM读取指令instr
- pc若为0则将pc置为初始值0x00003000，地址置为0

##  模块四：Control

- 结合MIPS指令集，对op和rb进行判断，确定指令类型

- 结合指令对应的控制信号，输入为指令类型，输出为对应的控制信号

## 模块五：DM

- 所需要的存储空间为3072\*32位，考虑采用三片1024\*32位的RAM进行存储
- 32bit=4byte，所以最低两位是字内的字节地址，无意义
- 每片RAM的片内地址需要10位，因此2-11位作为片内地址
- 共有三片RAM，需要两位片选地址，12-13位作为片选地址

## 模块六：mips

### （一）直接应用前八个模块

- 结合前几个模块的功能，对每一个模块的输入输出端口添加对应含义的tunnel

### （二）直接翻译八个控制信号含义

- 按照控制信号含义，使用MUX对各自的功能进行直接翻译

# 四、思考题

## 问题一：

阅读下面给出的 DM 的输入示例中（示例 DM 容量为 4KB，即 32bit × 1024字），根据你的理解回答，这个 addr 信号又是从哪里来的？地址信号 addr 位数为什么是 [11:2] 而不是 [9:0] ？

> - addr 信号来自 ALU 算术逻辑单元的计算结果
> - addr 表示的是主存的字节地址，在 4KB 的存储空间中，字节地址可以用低 12 位来表示。然而，指令实际操作的内存是以字为单位的，因此低 2 位作为字内的字节地址，最终的字地址信号应为 [11:2]。

## 问题二：

思考上述两种控制器设计的译码方式，给出代码示例，并尝试对比各方式的优劣。

> ### 设计一：每个指令对应所有控制信号
> 
> 在这种设计中，控制器为每条指令直接指定相应的控制信号。这种方法的优点在于实现简单且直观，但当指令数量增多时，可能会变得繁琐。
> 
> #### Verilog 代码示例
> ```verilog
> module controller (
>     input [5:0] opcode,
>     output reg ALUOp,
>     output reg MemRead,
>     output reg MemWrite,
>     output reg RegWrite,
>     output reg ALUSrc,
>     output reg Jump
> );
>     always @(*) begin
>         case (opcode)
>             6'b000000: begin
>                 ALUOp = 1;
>                 MemRead = 0;
>                 MemWrite = 0;
>                 RegWrite = 1;
>                 ALUSrc = 0;
>                 Jump = 0;
>             end
>             6'b100011: begin
>                 ALUOp = 0;
>                 MemRead = 1;
>                 MemWrite = 0;
>                 RegWrite = 1;
>                 ALUSrc = 1;
>                 Jump = 0;
>             end
>             6'b101011: begin
>                 ALUOp = 0;
>                 MemRead = 0;
>                 MemWrite = 1;
>                 RegWrite = 0;
>                 ALUSrc = 1;
>                 Jump = 0;
>             end
>             default: begin
>                 ALUOp = 0;
>                 MemRead = 0;
>                 MemWrite = 0;
>                 RegWrite = 0;
>                 ALUSrc = 0;
>                 Jump = 0;
>             end
>         endcase
>     end
> endmodule
> ```
> 
> ### 设计二：每个控制信号由指令类型决定
> 
> 在这种设计中，控制信号的值由指令类型和对应的控制逻辑决定。这种方式更为模块化，有利于扩展和维护。
> 
> #### Verilog 代码示例
> ```verilog
> module control_signal_decoder (
>     input [5:0] opcode,
>     output reg [1:0] ALUOp,
>     output reg MemRead,
>     output reg MemWrite,
>     output reg RegWrite,
>     output reg ALUSrc,
>     output reg Jump
> );
>     always @(*) begin
>         ALUOp = 2'b00;
>         MemRead = 0;
>         MemWrite = 0;
>         RegWrite = 0;
>         ALUSrc = 0;
>         Jump = 0;
>         case (opcode)
>             6'b000000: begin 
>                 ALUOp = 2'b10;
>                 RegWrite = 1;
>             end
>             6'b100011: begin
>                 ALUOp = 2'b00;
>                 MemRead = 1;
>                 RegWrite = 1;
>                 ALUSrc = 1;
>             end
>             6'b101011: begin
>                 ALUOp = 2'b00;
>                 MemWrite = 1;
>                 ALUSrc = 1;
>             end
>         endcase
>     end
> endmodule
> ```
> 
> ### 优缺点
> 
> | 设计方式               | 优点                                                         | 缺点                                                         |
> | ---------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
> | **指令对应控制信号**   | 1. 实现简单，逻辑清晰。<br>2. 易于理解和调试。               | 1. 随着指令增多，代码变得冗长。<br>2. 扩展性差，修改或新增指令复杂。 |
> | **控制信号由指令决定** | 1. 模块化设计，更易于管理和维护。<br>2. 灵活性高，便于扩展。 | 1. 实现复杂度较高，调试难度增加。<br>2. 需要仔细管理控制信号的组合。 |


## 问题三：
在相应的部件中，复位信号的设计都是同步复位，这与 P3 中的设计要求不同。请对比同步复位与异步复位这两种方式的 reset 信号与 clk 信号优先级的关系。
> - 同步复位
>   - 原理: 同步复位信号只有在时钟信号的上升沿（或下降沿）时才能对电路的状态产生影>响。在时钟的有效边缘，如果复位信号被激活，电路将被复位。
>   - 优先级: 在同步复位中，复位信号的作用受到时钟信号的控制。因此，复位的优先级低于时钟信号。这意味着复位信号只有在时钟周期内有效时才能起作用，不会立即影响电路的状态。
> - 异步复位
>   - 原理: 异步复位信号可以在任何时刻对电路的状态产生影响，无论时钟信号的状态如何。复位信号一旦被激活，电路立即响应并复位。
>   - 优先级: 在异步复位中，复位信号的优先级高于时钟信号。这意味着当复位信号激活时，电路会立即复位，即使在时钟信号的有效边缘之间，也会产生影响。

## 问题四：
C 语言是一种弱类型程序设计语言。C 语言中不对计算结果溢出进行处理，这意味着 C 语言要求程序员必须很清楚计算结果是否会导致溢出。因此，如果仅仅支持 C 语言，MIPS 指令的所有计算指令均可以忽略溢出。 请说明为什么在忽略溢出的前提下，addi 与 addiu 是等价的，add 与 addu 是等价的。
> - `addi` 和 `addiu`：
>   - 无论是使用有符号还是无符号的立即数，相加的结果在 C 语言的上下文中都将被直接使用，而 不考虑溢出，因此可以看作是等价的。
>  - `add` 和 `addu`：
>    - 在 C 语言中，如果不处理溢出，两个寄存器相加的结果同样在所有情况下都是可以直接使用的，因此在不考虑溢出的情况下，它们也可以被视为等价。
