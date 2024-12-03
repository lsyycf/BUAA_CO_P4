`timescale 1ns / 1ps
module test;

	// Inputs
	reg clk;
	reg reset;

	// Instantiate the Unit Under Test (UUT)
	mips uut (
		.clk(clk), 
		.reset(reset)
	);

	initial begin
		clk = 0;
		reset = 0;
	end
	always #5 clk = ~clk;
      
endmodule

