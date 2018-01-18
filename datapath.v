module datapath(input clk, // recall from Lab 4 that KEY0 is 1 when NOT pushed

                // register operand fetch stage
                input [2:0]readnum,
                input [3:0] vsel,
                input loada,
                input loadb,

                // computation stage (sometimes called "execute")
                input [1:0]shift,
                input asel,
                input bsel,
                input [1:0]ALUop,
                input loadc,
                input loads,

                // set when "writing back" to register file
                input [2:0]writenum,
                input write,  
                //input [15:0] datapath_in ,

                // outputs
                output [2:0] status ,
                output [15:0] datapath_out, 
		
		//lab 6 additions
		input[15:0] mdata ,
		input [15:0] sximm8 ,input [8:0] PC, input [15:0] sximm5 );

		//wires
		wire [15:0] data_out;
		wire [15:0] dffa_out;
		wire [15:0] dffb_out;
		wire [15:0] shift_out;
		wire [15:0] Ain, Bin;
		wire [15:0] alu_to_C;
		wire [2:0] alu_to_status;
		wire [15:0] data_in;

	
	
 
mux4in mux1(mdata, sximm8, {7'b0, PC}, datapath_out, vsel , data_in);

register REGFILE(writenum, write, data_in, clk, readnum, data_out);

vDFFE1 inst_A(clk, loada, data_out, dffa_out);

muxb2 mux2(16'b0, dffa_out, asel ,Ain); 

vDFFE1 inst_B(clk, loadb, data_out, dffb_out);

shift  shit(dffb_out,shift_out,shift);

muxb2 mux3(sximm5, shift_out, bsel ,Bin); 
 
alu  lol(Ain, Bin, ALUop, alu_to_C, alu_to_status);

vDFFE1 inst_C(clk, loadc, alu_to_C, datapath_out);

vDFFE1 #(3) inst_status(clk, loads, alu_to_status, status);
endmodule


module mux4in( a3, a2, a1, a0, select ,out); 
parameter n = 16;
parameter m = 4;

input [m-1:0] select;
input [n-1:0] a2, a3, a1,a0;
output [n-1:0] out;
wire  [n-1:0] in;
wire [m-1:0] select;
reg [n-1:0] out;
always@(*)begin
case(select)
4'b0001: out =a0;
4'b0010: out =a1;
4'b0100: out = a2;
4'b1000: out = a3;
default: out =a0;
endcase
end
endmodule


module vDFFE1(clk, en, in, out);
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

module muxb2( a1,a0, select ,out); 
parameter n = 16;
parameter m = 1;

input [m-1:0] select;
input [n-1:0] a1,a0;
output [n-1:0] out;
wire  [n-1:0] in;
wire [m-1:0] select;
reg [n-1:0] out;
always@(*)begin
case(select)
1'b0: out =a0;
1'b1: out =a1;

default: out ={n{1'bx}};
endcase
end
endmodule



module datapath_test;

reg clk;  // recall from Lab 4 that KEY0 is 1 when NOT pushed

                // register operand fetch stage
reg [2:0]readnum;
reg vsel;
reg loada;
reg loadb;

                // computation stage (sometimes called "execute")
reg [1:0]shift;
reg asel;
reg bsel;
reg [1:0]ALUop;
reg loadc;
reg loads;

                // set when "writing back" to register file
reg [2:0]writenum;
reg write;
reg [15:0] datapath_in ;

                // outputs
wire status ;
wire [15:0] datapath_out;

datapath dut(clk, readnum,vsel, loada,loadb,shift, asel, bsel, ALUop,loadc,loads,writenum,write,datapath_in ,status ,datapath_out);

initial forever begin
    clk = 0; #5;
    clk = 1; #5;
  end

initial begin
#5;
datapath_in = 16'd1; //Testing of addition of 1 and 1... expected outcome 2
vsel = 1'b1;
writenum = 3'b011;
write = 1'b1;
#10;
datapath_in = 16'd1;
vsel = 1'b1;
writenum = 3'b101;
write = 1'b1;
#10;

readnum = 3'b011;
loadb = 1'b1;
#10;
readnum = 3'b101;
loada = 1'b1;
#10;
shift = 2'b00;
bsel = 0;
asel = 0;
ALUop = 2'b00;
loadc = 1'b1;
#10;
writenum = 3'b010;
write = 1'b1;
vsel = 0;
#10;


#5;
datapath_in = 16'd2; //testing subtraction 2-2 = 0
vsel = 1'b1;
writenum = 3'b010;
write = 1'b1;
#10;
datapath_in = 16'd2;
vsel = 1'b1;
writenum = 3'b000;
write = 1'b1;
#10;

readnum = 3'b010;
loadb = 1'b1;
#10;
readnum = 3'b000;
loada = 1'b1;
ALUop = 2'b01;
#10;
shift = 2'b00;
bsel = 0;
asel = 0;
loadc = 1'b1;
#10;

$stop;
end
endmodule
