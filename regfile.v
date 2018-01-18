module register(writenum, write, data_in, clk, readnum, data_out);

input [2:0] writenum;
input [2:0] readnum;
input write;
input [15:0] data_in;
input clk;
output [15:0] data_out;

//Top decoder
//output [7:0] Decout2;
wire [7:0] Decout2;

//Bottom decoder
//output [7:0] Decout1;
wire [7:0] Decout1;

//Top Decoder Andgate wire
wire [7:0] andwire;

//Output wire from Load Enable
wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;

Dec #(3,8) inst_1(readnum, Decout1);
Dec #(3,8) inst_2(writenum, Decout2);

assign andwire[0] = Decout2[0] & write;
assign andwire[1] = Decout2[1] & write;
assign andwire[2] = Decout2[2] & write;
assign andwire[3] = Decout2[3] & write;
assign andwire[4] = Decout2[4] & write;
assign andwire[5] = Decout2[5] & write;
assign andwire[6] = Decout2[6] & write;
assign andwire[7] = Decout2[7] & write;

vDFFE R00(clk, andwire[0], data_in, R0);
vDFFE R01(clk, andwire[1], data_in, R1);
vDFFE R02(clk, andwire[2], data_in, R2);
vDFFE R03(clk, andwire[3], data_in, R3);
vDFFE R04(clk, andwire[4], data_in, R4);
vDFFE R05(clk, andwire[5], data_in, R5);
vDFFE R06(clk, andwire[6], data_in, R6);
vDFFE R07(clk, andwire[7], data_in, R7);
 

muxb8 hello(R7,R6,R5,R4,R3,R2,R1,R0,Decout1,data_out); 
 
endmodule

module Dec(a, b);
parameter n;
parameter m;

input [n-1:0] a;
output [m-1:0] b;

wire [m-1:0] b = 1 << a;
endmodule

module vDFFE(clk, en, in, out);
parameter n = 16;
input clk, en;
input [n-1:0] in;
output [n-1:0] out;
reg [n-1:0] out;
wire [n-1:0] next_out;

assign next_out = en ? in : out;

always @(posedge clk)
  out = next_out;
endmodule

module muxb8( a7,a6,a5,a4,a3,a2,a1,a0,select ,out);  //reference to http://electrosofts.com/verilog :)
parameter n = 16;
parameter m = 8;

input [m-1:0] select;
input [n-1:0] a7,a6,a5,a4,a3,a2,a1,a0;
output [n-1:0] out;
//wire  [n-1:0] in;
//wire [m-1:0] select;
reg [n-1:0] out;
always@(*)begin
case(select)
8'b00000001: out =a0;
8'b00000010: out =a1;
8'b00000100: out=a2;
8'b00001000: out=a3;
8'b00010000: out=a4;
8'b00100000: out=a5;
8'b01000000: out=a6;
8'b10000000: out=a7;
default: out ={n{1'bx}};
endcase
end
endmodule




module test_reg;

reg [2:0] writenum, readnum;
reg write, clk;
reg [15:0] data_in;
wire [15:0] data_out;

register dut(writenum, write, data_in, clk, readnum, data_out);


initial begin

clk = 1'b0; //Checking if the number 42 is written into the register. expected output 42
#5;
clk = 1'b1;
writenum = 3'b100;
write = 1'b1;
data_in =16'd42;

#10;
clk = 0;
readnum = 3'b100;

#10;

end
endmodule


