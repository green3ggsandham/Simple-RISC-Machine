module alu(Ain, Bin, ALUop, alu_to_C, alu_to_status);
input [15:0] Ain, Bin;
input [1:0] ALUop;
output [15:0] alu_to_C;
output [2:0] alu_to_status;
reg [15:0] alu_to_C;
wire [2:0] alu_to_status;
wire [15:0] alu_to_D, alu_to_E;

wire  ovf, ovf1;
AddSub #(16) inst11(Ain, Bin, 0, alu_to_D, ovf1);
AddSub #(16) inst12(Ain, Bin, 1, alu_to_E, ovf);


always@(*) begin

if (ALUop == 2'b00)begin
  alu_to_C = alu_to_D;

  end

else if (ALUop == 2'b01)begin
  alu_to_C = alu_to_E;
  end

else if (ALUop == 2'b10)begin
  alu_to_C = Ain & Bin; 
end

else begin
  alu_to_C = ~Bin;
end

end

assign alu_to_status[2] = ovf|ovf1;
assign alu_to_status[1] = alu_to_C[15];
assign alu_to_status[0] = ~|alu_to_C;






endmodule 



module AddSub(a,b,sub,s,ovf) ;
  parameter n = 8 ;
  input [n-1:0] a, b ;
  input sub ;           // subtract if sub=1, otherwise add
  output [n-1:0] s ;
  output ovf ;          // 1 if overflow
  wire c1, c2 ;         // carry out of last two bits
  wire ovf = c1 ^ c2 ;  // overflow if signs don't match

  // add non sign bits
  Adder1 #(n-1) ai(a[n-2:0],b[n-2:0]^{n-1{sub}},sub,c1,s[n-2:0]) ;
  // add sign bits
  Adder1 #(1)   as(a[n-1],b[n-1]^sub,c1,c2,s[n-1]) ;
endmodule


module Adder1(a,b,cin,cout,s) ;
  parameter n = 8 ;
  input [n-1:0] a, b ;
  input cin ;
  output [n-1:0] s ;
  output cout ;
  wire [n-1:0] s;
  wire cout ;

  assign {cout, s} = a + b + cin ;
endmodule 




module testalu;

reg [15:0] Ain, Bin;
reg [1:0] ALUop;
wire [15:0] alu_to_C;
wire alu_to_status;

alu dut(Ain, Bin, ALUop, alu_to_C, alu_to_status);

initial begin
#5;
Ain = 16'd5; //Testing addition of 1 and 5 expects 6
Bin = 16'd1;
ALUop = 2'b00;
#10;
Ain = 16'd6; //Testing subtraction of 6 and 4 expects 2
Bin = 16'd4;
ALUop = 2'b01;
#10;
Ain = 16'd6; //Testing anding of 6 and 4 expect 0s
Bin = 16'd4;
ALUop = 2'b10;
#10;
Bin = 16'd10; // Testing not of b expect 0s to 1s, 1s to 0s
end
endmodule 
