`define MREAD  2'b11 
`define MWRITE 2'b01 
`define MNONE  2'b00

module lab8_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5, CLOCK_50);
  input [3:0] KEY;
  input [9:0] SW;
  output [9:0] LEDR; 
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  input CLOCK_50;
  
  

 
  wire write , msel , read_sel , tri_sel ,clk ,reset , tri_load , load; //wires
  wire [1:0] mem_cmd ;
  wire [8:0] mem_addr ;
  wire [15:0] read_data , write_data , din ,dout ;
  wire [7:0] read_address , write_address , LED;
  
  assign read_address = mem_addr [7:0] ;
  assign write_address = mem_addr [7:0] ;
  assign read_sel = mem_cmd[0] & mem_cmd [1] ;
  assign msel = ~mem_addr [8] ;
  assign tri_sel = msel & mem_cmd[1] & mem_cmd [0]  ; //anded results 
  assign read_data = tri_sel ? dout : tri_load ? SW[7:0] :16'bz ; //tristate driver
   
  
  assign clk = CLOCK_50 ;
  assign reset = ~KEY[1] ;
  assign write = msel & ~mem_cmd[1] & mem_cmd [0] ;
  //assign LEDR = LED ;
  

  assign HEX0 = 7'b1111111;
  assign HEX1 = 7'b1111111;
  assign HEX2 = 7'b1111111;
  assign HEX3 = 7'b1111111;
  assign HEX4 = 7'b1111111;
  assign HEX5 = 7'b1111111; // disabled HEXes
 

in IN_SLIDER(mem_cmd,mem_addr,tri_load);
out OUT_LED(mem_cmd,mem_addr,load) ;
 vDFFE #8 TMJ(clk ,load ,write_data[7:0] ,LED) ;
 RAM #(16 ,8) MEM(clk,read_address,write_address,write,write_data,dout) ; //read-write memory instantiation 
 cpu CPU(clk,reset,read_data,mem_addr,mem_cmd,write_data, LEDR[8]);

         
endmodule


module in(mem_cmd,mem_addr,tri_load);

input [1:0] mem_cmd ;
input [8:0] mem_addr ;
output tri_load;

reg tri_load ;

always @* begin 
if(mem_cmd==2'b11 & mem_addr== 9'b101000000) begin
 tri_load=1'b1 ;
end
end
endmodule
  
module out(mem_cmd,mem_addr,load);

input [1:0] mem_cmd ;
input [8:0] mem_addr ;
output load;

reg load ;

always @* begin 
if(mem_cmd==2'b01 & mem_addr== 9'b100000000) begin
  load=1'b1 ;
end
end
endmodule

module sseg(in,segs);
  input [3:0] in;
  output reg [6:0] segs;

  // NOTE: The code for sseg below is not complete: You can use your code from
  // Lab4 to fill this in or code from someone else's Lab4.  
  //
  // IMPORTANT:  If you *do* use someone else's Lab4 code for the seven
  // segment display you *need* to state the following three things in
  // a file README.txt that you submit with handin along with this code: 
  //
  //   1.  First and last name of student providing code
  //   2.  Student number of student providing code
  //   3.  Date and time that student provided you their code
  //
  // You must also (obviously!) have the other student's permission to use
  // their code.
  //
  // To do otherwise is considered plagiarism.
  //
  // One bit per segment. On the DE1-SoC a HEX segment is illuminated when
  // the input bit is 0. Bits 6543210 correspond to:
  //
  //    0000
  //   5    1
  //   5    1
  //    6666
  //   4    2
  //   4    2
  //    3333
  //
  // Decimal value | Hexadecimal symbol to render on (one) HEX display
  //             0 | 0
  //             1 | 1
  //             2 | 2
  //             3 | 3
  //             4 | 4
  //             5 | 5
  //             6 | 6
  //             7 | 7
  //             8 | 8
  //             9 | 9
  //            10 | A
  //            11 | b
  //            12 | C
  //            13 | d
  //            14 | E
  //            15 | F

 always@(*) begin
if (in==4'b0000)begin
   segs = 7'b1000000;//0
end
else if (in==4'b0001)begin
  segs = 7'b1111001;//1
end
else if (in==4'b0010)begin
   segs = 7'b0100100;//2
end
else if (in==4'b0011)begin
   segs = 7'b0110000;//3
end
else if (in==4'b0100)begin
   segs = 7'b0011001;//4
end
else if (in==4'b0101)begin
   segs = 7'b0010010;//5
end
else if (in==4'b0110)begin
   segs = 7'b0000010;//6
end
else if (in==4'b0111)begin
   segs = 7'b1111000;//7
end
else if (in==4'b1000)begin
   segs = 7'b0000000;//8
end
else if (in==4'b1001)begin
   segs = 7'b0011000;//9
end
else if (in==4'b1010)begin
   segs = 7'b0001000;//A
end
else if (in==4'b1011)begin
   segs = 7'b0000011;//b
end
else if (in==4'b1100)begin
   segs = 7'b1000110;//C
end
else if (in==4'b1101)begin
   segs = 7'b0100001;//d
end
else if (in==4'b1110)begin
   segs = 7'b0000110;//E
end
else begin
   segs = 7'b0001110;  // this will output "F" 
end

end

endmodule

module vDFF(clk,D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;
  always @(posedge clk)
   
   Q<=D ;

endmodule

module lab7_tb ;

  reg [3:0] KEY;
  reg [9:0] SW;
  wire [9:0] LEDR; 
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

initial forever begin
    KEY[0] = 1; #5;
    KEY[0] = 0; #5;
  end
initial begin KEY[1]= 1 ;
end
endmodule 

