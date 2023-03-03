`include "global_config.v"

module sram
#(
  parameter DATA_W      = 53             ,
  parameter DEPTH       = 32             ,
  parameter ADDR_W      = $clog2(DEPTH)    
) (
    input  wire                  clk     , 
    input  wire                  cen     , 
    input  wire                  wen     , 
    input  wire [ADDR_W-1:0]     addr    ,
    input  wire [DATA_W-1:0]     wdata   ,   

    output reg  [DATA_W-1:0]     rdata     
);

  reg [DATA_W-1:0] ram [DEPTH-1:0] ;

  always @(posedge clk) begin
    if(cen && wen) begin
      ram[addr] <= wdata ;
    end
    rdata <= cen && !wen ? ram[addr] : {DATA_W{1'b0}};
  end

endmodule
