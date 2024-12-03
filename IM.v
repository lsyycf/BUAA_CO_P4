`timescale 1ns / 1ps
module IM(
    input  [31:0] nextPc,
    input  [ 0:0] clk   ,
    input  [ 0:0] reset ,
    output [31:0] nowPc ,
    output [31:0] instr
    );
	 
	 reg [31:0] ROM [0:4095];
	 reg [31:0] pc          ;
	 
	 wire [31:0] addr ;
	 wire [11:0] index;
	 
	 initial begin
		$readmemh("code.txt", ROM); 
		pc <= 32'h00003000;
	 end
	 
	 assign addr  = pc - 32'h00003000;
	 assign index = addr[13:2]       ;
	 assign instr = ROM [index]      ;
	 
	 always @(posedge clk) 
	 begin
		if (reset) 
		begin
			pc <= 32'h00003000;
		end 
		else 
		begin
			pc <= nextPc      ;
		end
	 end
	 
	 assign nowPc = pc;

endmodule
