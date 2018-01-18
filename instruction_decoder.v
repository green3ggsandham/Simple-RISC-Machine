module instruction_decoder(instruc_reg_out, nsel, ALUop, sximm5, sximm8, shift, readnum, writenum, op, opcode, cond); //FIND BITSIZE OF NSEL
input [15:0] instruc_reg_out;
input [2:0] nsel;
output [1:0] ALUop, shift, op;
output [2:0] readnum, writenum, cond, opcode;
output [15:0] sximm5, sximm8;
wire [4:0] imm5;
wire [7:0] imm8;
wire [2:0] Rn, Rd, Rm, muxout;


assign imm5 = instruc_reg_out[4:0];
assign imm8 = instruc_reg_out[7:0];
assign shift = instruc_reg_out[4:3];
assign opcode = instruc_reg_out[15:13];
assign op = instruc_reg_out[12:11];

assign Rn = instruc_reg_out[10:8];
assign Rd = instruc_reg_out[7:5];
assign Rm = instruc_reg_out[2:0];

assign sximm5 = {{11{imm5[4]}}, imm5};
assign sximm8 = {{8{imm8[7]}}, imm8};

assign ALUop = instruc_reg_out[12:11];

mux3in #(3) mux_instruc(Rn, Rd, Rm, nsel, muxout);

assign readnum = muxout;
assign writenum = muxout;

assign cond = instruc_reg_out[10:8];

endmodule





  
module mux3in(a2, a1, a0, select ,out); 
parameter n = 3;
parameter m = 3;

input [m-1:0] select;
input [n-1:0] a2,a1,a0;
output [n-1:0] out;
wire  [n-1:0] in;
wire [m-1:0] select;
reg [n-1:0] out;


always@(*)begin
case(select)
3'b001: out =a0;
3'b010: out =a1;
3'b100: out = a2;
default: out ={n{1'bx}};
endcase
end
endmodule
