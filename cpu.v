//NIMA SALEH LAB 7 CODE USED!!!

module cpu(clk,reset,read_data,mem_addr,mem_cmd,write_data, ledr);
input clk, reset;
input [15:0] read_data;
output [8:0] mem_addr ;
output [1:0] mem_cmd  ;
output [15:0] write_data;
output ledr;

reg exb;

//wires originating from control file fsm
wire [2:0] opcode, nsel;
wire [1:0] op;
wire loada, loadb, loadc, loads, asel, bsel , load_addr;
wire N ,V , Z ;
wire load_ir,load_pc,addr_sel , reset_pc ; // modified wires
wire [8:0] next_pc ; //modified wires
wire [3:0] vsel;
wire write;
reg [8:0] next_to_next_pc;

//wires from decoder
wire [1:0] ALUop, shift;
wire [15:0] sximm5, sximm8 ,out;
wire [2:0] readnum, writenum;

wire [15:0] mdata ;
wire [15:0] instruc_reg_out;
wire [8:0] PC , data_addr ;    
wire [2:0] status, cond;


assign N = status[1];
assign V = status[2];
assign Z = status[0];


assign next_pc = reset_pc ? 9'b0: next_to_next_pc ;
assign mem_addr = addr_sel ? PC : data_addr ;
assign mdata= read_data ;

always@*begin //sudo state machine that takes a condition and outputs a signal depending on status output
case({cond,op,opcode})
{3'b000, 2'b00, 3'b001}: exb=1'b1;
{3'b001, 2'b00, 3'b001}: exb= status[0];
{3'b010, 2'b00, 3'b001}: exb=~status[0];
{3'b011, 2'b00, 3'b001}: exb=status[1] ^ status[2];
{3'b100, 2'b00, 3'b001}: exb=(status[1] ^ status[2]) | status[0];
default exb = 0;
endcase
end

always@*begin
case(exb)
1'b0: next_to_next_pc = (PC + 9'b000000001); //Added input to mux depending on exb from state machine above
1'b1: next_to_next_pc = sximm8+PC+1;
default next_to_next_pc= 9'bxxxx;
endcase
end

state_machine  FSM(clk, reset, opcode, op, loada, loadb, loadc, loads, asel, bsel, nsel, vsel, write ,
       load_pc , reset_pc ,addr_sel, load_ir ,load_addr , mem_cmd, ledr );
vDFFE #9 D1(clk , load_pc ,next_pc , PC ) ;
instruction_decoder fit2(instruc_reg_out, nsel, ALUop, sximm5, sximm8, shift, readnum, writenum, op, opcode, cond);
datapath  DP(clk,readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, status, write_data, mdata, sximm8, PC,  sximm5 );
instruction_register fit4(clk, read_data, load_ir, instruc_reg_out);
vDFFE #9 D2(clk,load_addr,write_data[8:0],data_addr) ;

endmodule 



module Dec_cpu(a, b);
parameter n;
parameter m;

input [n-1:0] a;
output [m-1:0] b;

wire [m-1:0] b = 1 << a;
endmodule

module cpu_tb ;

reg clk, reset;
reg [15:0] read_data;
wire [8:0] mem_addr ;
wire [1:0] mem_cmd  ;

cpu DUT(clk,reset,read_data,mem_addr,mem_cmd);
initial begin
    clk = 0; #5;
    forever begin
      clk = 1; #5;
      clk = 0; #5;
    end
  end
initial begin 


reset=1 ; read_data=16'b1101000000000101  ; 
#100  ;
$display("%b %b",mem_addr,mem_cmd );
#100
reset=0 ; read_data=16'b1101000000000101 ; 
#100  
$display("%b %b",mem_addr,mem_cmd );
#100
reset=0 ; read_data=16'b0110000000100000 ; 
#100 
$display("%b %b",mem_addr,mem_cmd );
#100
reset=0 ; read_data=16'b1101001000000110  ; 
#100 
$display("%b %b",mem_addr,mem_cmd );
#100
reset=0 ; read_data=16'b1000001000100000 ; 
#100 
$display("%b %b",mem_addr,mem_cmd );
#100
reset=0 ; read_data=16'b1110000000000000  ; 
#100
$display("%b %b",mem_addr,mem_cmd );
$stop ;

end
endmodule 


