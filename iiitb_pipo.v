module iiitb_pipo(rst, clk, out);
input clk, rst;
output reg[3:0] out;
reg qbar;
always @ (posedge clk) begin  
      if (rst==0)  
         out <= 0;  
      else
      qbar <= ~out[3];
      out <= {{out[2:0]},qbar}; 
 
  end  
endmodule  
