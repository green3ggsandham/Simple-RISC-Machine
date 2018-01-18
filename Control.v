//NIMA SALEH LAB 7 CODE USED!!!

`define RES  4'b0000
`define IFA  4'b0001
`define IFB  4'b0010
`define UPC  4'b0011
`define SD   4'b0100
`define SGA  4'b0101
`define SGB  4'b0110
`define SAD  4'b0111
`define SWR  4'b1000
`define WI   4'b1001
`define HALT 4'b1010
`define MEM  4'b1011
`define MEK  4'b1100
`define MEC  4'b1101


module state_machine (clk, reset, opcode, op, loada, loadb, loadc, loads, asel, bsel, nsel, vsel, write ,
       load_pc , reset_pc ,addr_sel, load_ir , load_addr, mem_cmd, ledr );

input clk, reset ;
output loada, loadb, loadc, loads, asel, bsel;
input [2:0] opcode;
input [1:0] op;
output load_pc , reset_pc ,addr_sel , load_ir , load_addr;
output [1:0] mem_cmd ;
output [2:0] nsel;
output [3:0] vsel;
output  write, ledr;

wire [3:0] pre_state, state_next_reset, state_next;
reg [25:0] next;



vDFF #(4) dff1control(clk, state_next_reset, pre_state );

assign state_next_reset = reset ? `RES : state_next;

always @(*) begin
    casex ( {pre_state, opcode, op} )

      {`RES, 3'bxxx, 2'bxx} : next = {`IFA,2'b00,1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; //Starting in wait returning to wait
      {`IFA, 3'bxxx, 2'bxx} : next = {`IFB,2'b11,1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; //starting in wait moving to decoder
      {`IFB, 3'bxxx, 2'bxx} : next = {`UPC,2'b11,1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; //Starting in wait returning to wait
      {`UPC, 3'b001, 2'b00} : next = {`IFA, 2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; 
//Added led output for autograder in halt state
//Added state with new comand output goes to mux to select pc counter
      {`UPC, 3'bxxx, 2'bxx} : next = {`SD, 2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0};
																		//starting in wait moving to decoder
      //MOV
      {`SD, 3'b110, 2'b10}  : next = {`WI, 2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; //in decoder moving to write to register
      {`WI, 3'b110, 2'b10}  : next = {`IFA,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b100, 4'b0100, 1'b0}; //in write, writing #im8 to Rn using MOV
      //ADD
      {`SD, 3'b101, 2'b00}  : next = {`SGA,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; //Decoder to loading a
      {`SGA, 3'b101, 2'b00} : next = {`SGB,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b100, 4'b0000, 1'b0}; //loading a Rn move to loading b
      {`SGB, 3'b101, 2'b00} : next = {`SAD,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 3'b001, 4'b0000, 1'b0}; //loading b Rm moving to adder
      {`SAD, 3'b101, 2'b00} : next = {`SWR,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; //loading c moving to write register Rd
      {`SWR, 3'b101, 2'b00} : next = {`IFA,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010, 4'b0001, 1'b0};

			   											    //Copy one register value to another
      {`SD, 3'b110, 2'b00}  : next = {`SGB,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; //move from decoder to load b skipping load a
      {`SGB, 3'b110, 2'b00} : next = {`SAD,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 3'b001, 4'b0000, 1'b0}; //value is written into load b Rm
      {`SAD, 3'b110, 2'b00} : next = {`SWR,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 3'b000, 4'b0000, 1'b0};  //adds 0 from asel thus copying value into next Rd
      {`SWR, 3'b110, 2'b00} : next = {`IFA,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010, 4'b0001, 1'b0};

															//subtracts one reg value from another
															//checks for overflow
      {`SD, 3'b101, 2'b01}  : next = {`SGA,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; //Decoder to loading a
      {`SGA, 3'b101, 2'b01} : next = {`SGB,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b100, 4'b0000, 1'b0}; //loading a Rn move to loading b
      {`SGB, 3'b101, 2'b01} : next = {`SAD,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 3'b001, 4'b0000, 1'b0}; //loading b Rm moving to adder
      {`SAD, 3'b101, 2'b01} : next = {`IFA,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; //loading c moving to write register
     // {`SWR, 3'b101, 2'b01} : next = {`IFA,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010, 4'b0001, 1'b0};

//LDR
      {`SD,  3'b011, 2'b00} : next = {`SGA,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; //Decoder to loading a
      {`SGA, 3'b011, 2'b00} : next = {`SGB,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b100, 4'b0000, 1'b0}; //loading A into Rn loada=1 nsel 100
      {`SGB, 3'b011, 2'b00} : next = {`SAD,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 3'b000, 4'b0000, 1'b0}; //loading Sximm5 bsel = 1 loadc =1
      {`SAD, 3'b011, 2'b00} : next = {`MEM,2'b00,1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; //load_addr = 1
      {`MEM, 3'b011, 2'b00} : next = {`MEK,2'b11,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; //read
      {`MEK, 3'b011, 2'b00} : next = {`IFA,2'b11,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010, 4'b1000, 1'b0}; //write in rd write 1 nsel for rd

//STR
      {`SD,  3'b100, 2'b00} : next = {`SGA,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; 
      {`SGA, 3'b100, 2'b00} : next = {`SGB,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b100, 4'b0000, 1'b0}; 
      {`SGB, 3'b100, 2'b00} : next = {`SAD,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 3'b000, 4'b0000, 1'b0}; 
      {`SAD, 3'b100, 2'b00} : next = {`MEM,2'b00,1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; 
      {`MEM, 3'b100, 2'b00} : next = {`MEK,2'b00,1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010, 4'b0000, 1'b0};
      {`MEK, 3'b100, 2'b00} : next = {`MEC,2'b01,1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 3'b000, 4'b0000, 1'b0};
      {`MEC, 3'b100, 2'b00} : next = {`IFA,2'b01,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0};


//HALT
      {`SD,   3'b111, 2'b00} : next = {`HALT,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; //Decoder to Halt
      {`HALT, 3'bxxx, 2'bxx} : next = {`HALT,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b1}; //stay in halt until reset
     
															//Anding each bit
      {`SD,  3'b101, 2'b10} : next = {`SGA,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; 
      {`SGA, 3'b101, 2'b10} : next = {`SGB,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b100, 4'b0000, 1'b0}; 
      {`SGB, 3'b101, 2'b10} : next = {`SAD,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 3'b001, 4'b0000, 1'b0}; 
      {`SAD, 3'b101, 2'b10} : next = {`SWR,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; 
      {`SWR, 3'b101, 2'b10} : next = {`IFA,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010, 4'b0001, 1'b0};

															//Nots value in load b
      {`SD,  3'b101, 2'b11} : next = {`SGB,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 4'b0000, 1'b0}; //move from decoder to load b skipping load a
      {`SGB, 3'b101, 2'b11} : next = {`SAD,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 3'b001, 4'b0000, 1'b0}; //value is written into load b
      {`SAD, 3'b101, 2'b11} : next = {`SWR,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 3'b000, 4'b0000, 1'b0};  
      {`SWR, 3'b101, 2'b11} : next = {`IFA,2'b00,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010, 4'b0001, 1'b0};


	

	default: next =  26'bxxxxxxxxxxxxxxxxxxxxxxxxx;
endcase
end


assign {state_next, mem_cmd ,load_addr ,load_ir ,addr_sel , reset_pc ,load_pc, write, loada, loadb, loadc, loads, asel, bsel , nsel, vsel, ledr} = next;

endmodule

module vDFFcontrol (clk, in, out);
parameter n = 1;
input clk;
input [n-1:0] in;
output reg [n-1:0] out;

always @(posedge clk)
out = in; 
endmodule 
