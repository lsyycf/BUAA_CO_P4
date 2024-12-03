`timescale 1ns / 1ps
module Control(
    input  [5:0] op       ,
    input  [5:0] rb       ,
    output [0:0] RegWrite ,
    output [1:0] RegAddrOp,
    output [1:0] RegDataOp,
    output [0:0] MemWrite ,
    output [0:0] MemAddrOp,
    output [0:0] MemDataOp,
    output [0:0] ALUIn1Op ,
    output [1:0] ALUIn2Op ,
    output [2:0] PCOp     ,
    output [1:0] ExtOp    ,
    output [2:0] ALUOp
);
    wire add;
    wire sub;
    wire ori;
    wire lw ;
    wire sw ;
    wire beq;
    wire lui;
    wire jal;
    wire jr ;
    wire new;

    assign add = op == 6'b000000 && rb == 6'b100000;
    assign sub = op == 6'b000000 && rb == 6'b100010;
    assign ori = op == 6'b001101                   ;
    assign lw  = op == 6'b100011                   ;
    assign sw  = op == 6'b101011                   ;
    assign beq = op == 6'b000100                   ;
    assign lui = op == 6'b001111                   ;
    assign jal = op == 6'b000011                   ;
    assign jr  = op == 6'b000000 && rb == 6'b001000;
    assign new = op == 6'b111111 && rb == 6'b111111;

    assign RegWrite  = add? 1'b1 :
							  sub? 1'b1 :
							  ori? 1'b1 :
							  lw ? 1'b1 :
							  sw ? 1'b0 :
							  beq? 1'b0 :
							  lui? 1'b1 :
							  jal? 1'b1 :
							  jr ? 1'b0 :
							  new? 1'b0 : 1'b0;

    assign RegAddrOp = add? 2'b01 :
                       sub? 2'b01 :
                       ori? 2'b00 :
                       lw ? 2'b00 :
                       sw ? 2'b00 :
                       beq? 2'b00 :
                       lui? 2'b00 :
                       jal? 2'b10 :
                       jr ? 2'b00 :
                       new? 2'b11 : 2'b00;

    assign RegDataOp = add? 2'b00 :
                       sub? 2'b00 :
                       ori? 2'b00 :
                       lw ? 2'b01 :
                       sw ? 2'b00 :
                       beq? 2'b00 :
                       lui? 2'b00 :
                       jal? 2'b10 :
                       jr ? 2'b00 :
                       new? 2'b11 : 2'b00;

    assign MemWrite  = add? 1'b0 :
							  sub? 1'b0 :
							  ori? 1'b0 :
							  lw ? 1'b0 :
							  sw ? 1'b1 :
							  beq? 1'b0 :
							  lui? 1'b0 :
							  jal? 1'b0 :
							  jr ? 1'b0 :
							  new? 1'b0 : 1'b0;

    assign MemAddrOp = add? 1'b0 :
							  sub? 1'b0 :
							  ori? 1'b0 :
							  lw ? 1'b0 :
							  sw ? 1'b0 :
							  beq? 1'b0 :
							  lui? 1'b0 :
							  jal? 1'b0 :
							  jr ? 1'b0 :
							  new? 1'b1 : 1'b0;

    assign MemDataOp = add? 1'b0 :
							  sub? 1'b0 :
							  ori? 1'b0 :
							  lw ? 1'b0 :
							  sw ? 1'b0 :
							  beq? 1'b0 :
							  lui? 1'b0 :
							  jal? 1'b0 :
							  jr ? 1'b0 :
							  new? 1'b1 : 1'b0;

    assign ALUIn1Op  = add? 1'b0 :
							  sub? 1'b0 :
							  ori? 1'b0 :
							  lw ? 1'b0 :
							  sw ? 1'b0 :
							  beq? 1'b0 :
							  lui? 1'b0 :
							  jal? 1'b0 :
							  jr ? 1'b0 :
							  new? 1'b1 : 1'b0;

    assign ALUIn2Op  = add? 2'b00 :
                       sub? 2'b00 :
                       ori? 2'b01 :
                       lw ? 2'b01 :
                       sw ? 2'b01 :
                       beq? 2'b00 :
                       lui? 2'b01 :
                       jal? 2'b00 :
                       jr ? 2'b00 :
                       new? 2'b10 : 2'b00;

    assign PCOp      = add? 3'b000 :
                       sub? 3'b000 :
                       ori? 3'b000 :
                       lw ? 3'b000 :
                       sw ? 3'b000 :
                       beq? 3'b001 :
                       lui? 3'b000 :
                       jal? 3'b010 :
                       jr ? 3'b011 :
                       new? 3'b100 : 3'b000;
                       
    assign ExtOp     = add? 2'b00 :
                       sub? 2'b00 :
                       ori? 2'b01 :
                       lw ? 2'b00 :
                       sw ? 2'b00 :
                       beq? 2'b00 :
                       lui? 2'b00 :
                       jal? 2'b00 :
                       jr ? 2'b00 :
                       new? 2'b10 : 2'b00;

    assign ALUOp     = add? 3'b000 :
                       sub? 3'b001 :
                       ori? 3'b010 :
                       lw ? 3'b000 :
                       sw ? 3'b000 :
                       beq? 3'b100 :
                       lui? 3'b011 :
                       jal? 3'b000 :
                       jr ? 3'b000 :
                       new? 3'b101 : 3'b000;
endmodule
