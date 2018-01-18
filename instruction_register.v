module instruction_register (clk, in, load, instruc_reg_out);

input [15:0] in;
input load, clk;
output reg [15:0] instruc_reg_out;

always @(posedge clk) begin

if (load ==1) begin
instruc_reg_out = in;
end
end

endmodule


