module shift(loadbin,shiftout,shift);
output reg [15:0] shiftout;
input [15:0] loadbin;
input [1:0] shift;

always@(*) begin

if (shift == 2'b00)begin
  shiftout= loadbin;
end

else if (shift == 2'b01)begin
  shiftout = loadbin << 1;
  
end

else if (shift == 2'b10)begin
   shiftout = loadbin >> 1;

end

else begin
   shiftout = loadbin >> 1;
   if (loadbin>=16'b1000000000000000 && shiftout < 16'b1000000000000000)begin
       shiftout = shiftout + 16'b1000000000000000;
	end
   else if (loadbin>=16'b1000000000000000 && shiftout >= 16'b1000000000000000)begin
        shiftout = shiftout;
    end
   else begin
        shiftout = shiftout;
	end
end

end
endmodule 


module test_shift;

reg [15:0] loadbin;
reg [1:0] shift;
wire [15:0] shiftout;

shift dut(loadbin,shiftout,shift);

initial begin

loadbin = 16'b1111000011001111;//shift case to the right shows a shift to the right,left,and the msb say the same as load bin
shift = 2'b00; //stay same
#5;
shift = 2'b01; //shift left
#5;
shift = 2'b10; //shift right
#5;
shift = 2'b11; //shifts to right, left most bit should change from 0 to 1.
#5;
loadbin = 16'b0011000011001111;
shift = 2'b00;
#5;
shift = 2'b01;
#5;
shift = 2'b10;
#5;
shift = 2'b11; //shifts right, lmb should stay at 0
#5;
loadbin = 16'b1111000011001111;
shift = 2'b00;
#5;
shift = 2'b01;
#5;
shift = 2'b10;
#5;
shift = 2'b11; // shifts right, lmb shoulld change from 0 to 1
#5;
loadbin = 16'b0111000011001111;
shift = 2'b00;
#5;
shift = 2'b01;
#5;
shift = 2'b10;
#5;
shift = 2'b11;
#5;
end
endmodule
