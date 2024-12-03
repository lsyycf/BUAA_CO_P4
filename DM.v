`timescale 1ns / 1ps
module DM(
	 input  [31:0] pc     ,
    input  [ 0:0] clk    ,
    input  [ 0:0] reset  ,
    input  [ 0:0] WE     ,
    input  [31:0] memAddr,
    input  [31:0] memData,
    output [31:0] memRead
    );
	 
	 reg [31:0] RAM [0:4095];
	 integer i;
	 
	 wire [11:0] index;
	 
	 initial
	 begin
		for(i = 0; i < 4096; i = i + 1)
		begin
			RAM[i] <= 0;
		end
	 end
	 
	 assign index = memAddr[13:2];
	 
	 always @(posedge clk) 
	 begin
		if (reset)
		begin
			for (i = 0; i < 4096; i = i + 1) begin
				RAM[i] <= 0;
			end
		end 
		else 
		begin
			if (WE) 
			begin
				RAM[index] <= memData;
				$display("@%h: *%h <= %h", pc, memAddr, memData);
			end
		end
	 end
	 
	 assign memRead = RAM[index];

endmodule
