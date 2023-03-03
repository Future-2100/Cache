`include "global_config.v"

module regfile
#(
  parameter DEPTH  = 32,
  parameter ADDR_W = $clog2(DEPTH),
  parameter DATA_W = 1
) (
  input   wire                clk   ,
  input   wire                reset ,

  input   wire  [ADDR_W-1:0]  raddr ,
  output  wire  [DATA_W-1:0]  rdata ,

  input   wire                wen   ,
  input   wire  [ADDR_W-1:0]  waddr ,
  input   wire  [DATA_W-1:0]  wdata 
);

  wire  [DATA_W-1:0]  reg_data[DEPTH-1:0];
  wire  [DEPTH-1:0]   reg_wen;

  genvar i;
  generate
    for(i=0; i<DEPTH; i=i+1) begin
      assign reg_wen[i] = ( waddr == i ) && wen ;
      dff #(DATA_W) reg_data_dff(clk, reset, reg_wen[i], wdata, reg_data[i] );
    end
  endgenerate

  assign  rdata = reg_data[raddr];

endmodule

