`include "global_config.v"

module dff
#(
  parameter DATA_W = 1
) (
  input   wire                 clk    ,
  input   wire                 reset  ,
  input   wire                 en     ,
  input   wire   [DATA_W-1:0]  d      ,
  output  wire   [DATA_W-1:0]  q       
);

reg [DATA_W-1:0] reg_d ;
always@(posedge clk) begin
  if( reset == `RESET_ENABLE)
    reg_d <= {DATA_W{1'b0}};
  else if (en)
    reg_d <= d ;
end

assign q = reg_d ;

endmodule

