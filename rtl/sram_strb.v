`include "global_config.v"

module sram_wstrb
#(
  parameter DATA_W    = 512            ,
  parameter DEPTH     = 32             ,
  parameter ADDR_W    = $clog2(DEPTH)  ,
  parameter WSTRB_W   = DATA_W/8
) (
    input  wire                  clk     , 
    input  wire                  cen     , 
    input  wire                  wen     , 
    input  wire [ADDR_W-1:0]     addr    ,
    input  wire [DATA_W-1:0]     wdata   ,   
    input  wire [WSTRB_W-1:0]    wstrb   , 

    output reg  [DATA_W-1:0]     rdata    
);

  reg   [DATA_W-1:0] ram [DEPTH-1:0] ;
  wire  [DATA_W-1:0] wmask           ;

  genvar i;
  generate 
    for(i=0; i < WSTRB_W; i=i+1) begin
      assign wmask[(i+1)*8-1:i*8] = {8{wstrb[i]}} ;
    end
  endgenerate

  always @(posedge clk) begin
    if(cen && wen) begin
      ram[addr] <= (wdata & wmask) | (ram[addr] & ~wmask);
    end
    rdata <= cen && !wen ? ram[addr] : {DATA_W{1'b0}};
  end

endmodule

