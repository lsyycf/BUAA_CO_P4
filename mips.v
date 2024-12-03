`timescale 1ns / 1ps
module mips(
	 input clk  ,
    input reset
    );
	 
	 wire [31:0] nextPc   ;
	 wire [31:0] nowPc    ;
	 wire [31:0] instr    ;
	 wire [ 5:0] op       ;
	 wire [ 5:0] rb       ;
	 wire [ 4:0] rs       ;
	 wire [ 4:0] rt       ;
	 wire [ 4:0] rd       ;
	 wire [ 4:0] ra       ;
	 wire [15:0] imm      ;
	 wire [25:0] index    ;
	 wire [31:0] jump     ;
    wire [ 0:0] RegWrite ;
    wire [ 1:0] RegAddrOp;
    wire [ 1:0] RegDataOp;
    wire [ 0:0] MemWrite ;
    wire [ 0:0] MemAddrOp;
    wire [ 0:0] MemDataOp;
    wire [ 0:0] ALUIn1Op ;
    wire [ 1:0] ALUIn2Op ;
    wire [ 2:0] PCOp     ;
    wire [ 1:0] ExtOp    ;
    wire [ 2:0] ALUOp    ;
	 wire [31:0] regRead1 ;
	 wire [31:0] regRead2 ;
	 wire [31:0] ALUIn1   ;
	 wire [31:0] ALUIn2   ;
	 wire [31:0] res      ;
	 wire [31:0] memRead  ; 
	 wire [31:0] memAddr  ;
	 wire [31:0] memData  ;
	 wire [ 4:0] writeAddr;
	 wire [31:0] writeData;
	 wire [31:0] extend   ;
	 
	 assign op    = instr[31:26]  ;
	 assign rb    = instr[ 5: 0]  ;
	 assign rs    = instr[25:21]  ;
	 assign rt    = instr[20:16]  ;
	 assign rd    = instr[15:11]  ;
	 assign ra    = instr[10: 6]  ;
	 assign imm   = instr[15: 0]  ;
	 assign index = instr[25: 0]  ;
	 assign jump  = {{6'b0},index};
	 
	 assign nextPc = (PCOp == 3'b000)? (nowPc + 32'd4):
						  (PCOp == 3'b001)? (res == 32'b0)? (nowPc + 32'd4 + (extend << 2)) : (nowPc + 32'd4) :
						  (PCOp == 3'b010)? (jump << 2)    :
						  (PCOp == 3'b011)? regRead1       :
						  (PCOp == 3'b100)? 32'h00003000   :
						  32'h00003000;
	 
	 IM IM_instance(
       .nextPc(nextPc),
       .clk   (clk)   ,
       .reset (reset) ,
       .nowPc (nowPc) ,
       .instr (instr)
    );
	 
	 Control Control_instance(
            .op       (op)       ,
			   .rb       (rb)       ,
			   .RegWrite (RegWrite) ,
			   .RegAddrOp(RegAddrOp),
			   .RegDataOp(RegDataOp),
			   .MemWrite (MemWrite) ,
			   .MemAddrOp(MemAddrOp),
			   .MemDataOp(MemDataOp),
			   .ALUIn1Op (ALUIn1Op) ,
			   .ALUIn2Op (ALUIn2Op) ,
			   .PCOp     (PCOp)     ,
			   .ExtOp    (ExtOp)    ,
			   .ALUOp    (ALUOp)
    );
	 
	 assign writeAddr = (RegAddrOp == 2'b00)? rt    :
							  (RegAddrOp == 2'b01)? rd    :
							  (RegAddrOp == 2'b10)? 5'd31 :
							  (RegAddrOp == 2'b11)? 5'b0  :
							  5'b0;
							  
	 assign writeData = (RegDataOp == 2'b00)? res             :
							  (RegDataOp == 2'b01)? memRead         :
							  (RegDataOp == 2'b10)? (nowPc + 32'd4) :
							  (RegDataOp == 2'b11)? 32'b0           :
							  32'b0;
							  
	 GRF GRF_instance(
	     .pc       (nowPc)    ,
        .clk      (clk)      ,
        .reset    (reset)    ,
        .reg1     (rs)       ,
        .reg2     (rt)       ,
        .writeAddr(writeAddr),
        .WE       (RegWrite) ,
        .writeData(writeData),
        .regRead1 (regRead1) ,
        .regRead2 (regRead2)
     );
	 
	 assign extend = (ExtOp == 2'b0)? {{16{imm[15]}},imm[15:0]} :
						  (ExtOp == 2'b1)? {16'b0,imm[15:0]}         :
						  32'b0;
						  
	 assign ALUIn1 = (ALUIn1Op == 1'b0)? regRead1 :
						  (ALUIn1Op == 1'b1)? 32'b0    :
						  32'b0;
						  
	 assign ALUIn2 = (ALUIn2Op == 2'b00)? regRead2 :
						  (ALUIn2Op == 2'b01)? extend   :
						  (ALUIn2Op == 2'b10)? 32'b0    :
						  32'b0;
						  
	 ALU ALU_instance(
        .ALUIn1(ALUIn1),
        .ALUIn2(ALUIn2),
        .ALUOp(ALUOp)  ,
        .res(res)
    );
	 
	 assign memAddr = (MemAddrOp == 1'b0)? res   :
							(MemAddrOp == 1'b1)? 32'b0 :
							32'b0;
							
	 assign memData = (MemDataOp == 2'b00)? regRead2 :
							(MemDataOp == 2'b01)? extend   :
							(MemDataOp == 2'b10)? 32'b0    :
							32'b0;
							
	 DM DM_instance(
		 .pc     (nowPc)   ,
       .clk    (clk)     ,
       .reset  (reset)   ,
       .WE     (MemWrite),
       .memAddr(memAddr) ,
       .memData(memData) ,
       .memRead(memRead)
    );
endmodule
