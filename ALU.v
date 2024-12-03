`timescale 1ns / 1ps
module ALU(
    input  [31:0] ALUIn1,
    input  [31:0] ALUIn2,
    input  [ 2:0] ALUOp ,
    output [31:0] res
    );
	 
	 assign res = (ALUOp == 3'b000)? ALUIn1 + ALUIn2 :
					  (ALUOp == 3'b001)? ALUIn1 - ALUIn2 :
					  (ALUOp == 3'b010)? ALUIn1 | ALUIn2 :
					  (ALUOp == 3'b011)? {ALUIn2[15:0], 16'h0000} :
					  (ALUOp == 3'b100)? ($signed(ALUIn1) == $signed(ALUIn2))? 32'd0 : ($signed(ALUIn1) > $signed(ALUIn2))? 32'd1 : ($signed(ALUIn1) < $signed(ALUIn2))? 32'd2 : 32'h00000000 :
					  32'h00000000;
					  
endmodule
