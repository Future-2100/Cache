`include "cache_rplc_def.v"

module cache_replace(
  input   wire                      clk         ,
  input   wire                      reset       ,

  input   wire                      info_miss       ,
  input   wire                      info_rplc_way   ,
  input   wire                      info_rplc_dirty ,
  input   wire                      info_rsp        ,
  input   wire                      wb_rsp          ,

  output  wire                      rplc_arb      ,

  input   wire  [`CACHE_INDEX_W-1:0]core_index    ,
  input   wire  [`CACHE_TAG_W-1:0]  core_tag      ,

  output  wire  [`AxID_W-1:0]       rplc_arid     ,
  output  wire  [`AxADDR_W-1:0]     rplc_araddr   ,
  output  wire  [`AxLEN_W-1:0]      rplc_arlen    ,
  output  wire  [`AxSIZE_W-1:0]     rplc_arsize   ,
  output  wire  [`AxBURST_W-1:0]    rplc_arburst  ,
  output  wire                      rplc_arlock   ,
  output  wire  [`AxCACHE_W-1:0]    rplc_arcache  ,
  output  wire  [`AxPORT_W-1:0]     rplc_arport   ,
  output  wire  [`AxQOS_W-1:0]      rplc_arqos    ,
  output  wire  [`AxREGION_W-1:0]   rplc_arregion ,
  output  wire                      rplc_arvalid  ,
  input   wire                      rplc_arready  ,

  input   wire  [`AxID_W-1:0]       rplc_rid      ,
  input   wire  [`AxDATA_W-1:0]     rplc_rdata    ,
  input   wire  [`AxRESP_W-1:0]     rplc_rresp    ,
  input   wire                      rplc_rlast    ,
  input   wire                      rplc_rvalid   ,
  output  wire                      rplc_rready   ,

  output  wire  [`SRAM_DATA_W-1:0]  rplc_rsp_data ,
  output  wire                      rplc_rsp      ,

  output  wire                        rplc_data_cen0      ,
  output  wire                        rplc_data_cen1      ,
  output  wire                        rplc_data_wen0      ,
  output  wire                        rplc_data_wen1      ,
  output  wire  [`SRAM_ADDR_W-1:0]    rplc_data_addr0     ,
  output  wire  [`SRAM_ADDR_W-1:0]    rplc_data_addr1     ,
  output  wire  [`SRAM_DATA_W-1:0]    rplc_data_wdata0    ,
  output  wire  [`SRAM_DATA_W-1:0]    rplc_data_wdata1    ,
  output  wire  [`SRAM_WSTRB_W-1:0]   rplc_data_wstrb0    ,
  output  wire  [`SRAM_WSTRB_W-1:0]   rplc_data_wstrb1    ,

  output  wire                        rplc_tag_cen0       ,
  output  wire                        rplc_tag_cen1       ,
  output  wire                        rplc_tag_wen0       ,
  output  wire                        rplc_tag_wen1       ,
  output  wire  [`SRAM_ADDR_W-1:0]    rplc_tag_addr0      ,
  output  wire  [`SRAM_ADDR_W-1:0]    rplc_tag_addr1      ,
  output  wire  [`SRAM_TAG_W-1:0]     rplc_tag_wdata0     ,
  output  wire  [`SRAM_TAG_W-1:0]     rplc_tag_wdata1     ,

  output  wire  [`CACHE_INDEX_W-1:0]  rplc_dirty_waddr0        ,
  output  wire  [`CACHE_INDEX_W-1:0]  rplc_dirty_waddr1        ,
  output  wire                        rplc_dirty_wen0          ,
  output  wire                        rplc_dirty_wen1          ,
  output  wire                        rplc_dirty_wdata0        ,
  output  wire                        rplc_dirty_wdata1        ,

  output  wire  [`CACHE_INDEX_W-1:0]  rplc_value_waddr0        ,
  output  wire  [`CACHE_INDEX_W-1:0]  rplc_value_waddr1        ,
  output  wire                        rplc_value_wen0          ,
  output  wire                        rplc_value_wen1          ,
  output  wire                        rplc_value_wdata0        ,
  output  wire                        rplc_value_wdata1        
);

  wire rplc_req = wb_rsp | (info_miss & !info_rplc_dirty & info_rsp) ;

  // read memory by axi-4 bus
  wire  [`AxADDR_W-1:0] rplc_araddr_in = { core_tag, core_index, {`CACHE_OFFSET_W{1'b0}}, {$clog2(`CORE_DATA_W/8){1'b0}} } ;

  wire  rplc_arvalid_en = rplc_req | (rplc_arvalid & rplc_arready) ;

  wire  rplc_arvalid_in = (  rplc_req                     & 1'b1 ) |
                          ( (rplc_arvalid & rplc_arready) & 1'b0 ) ;


  assign rplc_arid     = `RPLC_ARID       ;
  dff #(`AxADDR_W)rplc_araddr_dff(clk, reset, rplc_req, rplc_araddr_in, rplc_araddr);
  assign rplc_arlen    = `RPLC_ARLEN      ;
  assign rplc_arsize   = `RPLC_ARSIZE     ;
  assign rplc_arburst  = `RPLC_ARBURST    ;
  assign rplc_arlock   = `RPLC_ARLOCK     ;
  assign rplc_arcache  = `RPLC_ARCACHE    ;
  assign rplc_arport   = `RPLC_ARPORT     ;
  assign rplc_arqos    = `RPLC_ARQOS      ;
  assign rplc_arregion = `RPLC_ARREGION   ;
  dff rplc_arvalid_dff(clk, reset, rplc_arvalid_en, rplc_arvalid_in, rplc_arvalid) ;

  wire rplc_rdata_en = rplc_rvalid & rplc_rready & (rplc_rid==`RPLC_RID) & (rplc_rresp==`RPLC_RRESP);

  reg  [`CACHE_OFFSET_W-1:0] rcount;
  always@(posedge clk) begin
    if(reset==`RESET_ENABLE)
      rcount = 'b0;
    else if (rplc_req)
      rcount = 'b0;
    else if ( rplc_rdata_en )
      rcount = rcount + 1'b1;
  end
  
  assign rplc_rready = 1'b1;

  wire [`AxDATA_W-1:0] rplc_rdata_out[`CACHE_DATA_N-1:0];
  wire [`CACHE_DATA_N-1:0] rplc_rdata_out_en ;
  genvar i ;
  generate
    for(i=0; i<`CACHE_DATA_N; i=i+1) begin
      assign rplc_rdata_out_en[i] = ( rcount == i ) & rplc_rdata_en ;
      dff #(`AxDATA_W) rplc_rdata_dff(clk, reset, rplc_rdata_out_en[i], rplc_rdata, rplc_rdata_out[i]) ;
    end
  endgenerate

  
  wire  rplc_rsp_in = rplc_rlast & rplc_rdata_en ;
  dff rplc_rsp_dff(clk, reset, 1'b1, rplc_rsp_in, rplc_rsp) ;
  generate
    for(i=0; i<`CACHE_DATA_N; i=i+1) begin
      assign rplc_rsp_data[(i+1)*`CORE_DATA_W-1:i*`CORE_DATA_W] = rplc_rdata_out[i] ;
    end
  endgenerate

assign  rplc_arb = rplc_rsp ;
assign rplc_data_cen0    = rplc_rsp &  ~info_rplc_way;
assign rplc_data_wen0    = 1'b1                ;
assign rplc_data_addr0   = core_index          ;
assign rplc_data_wdata0  = rplc_rsp_data       ;
assign rplc_data_wstrb0  = {`SRAM_WSTRB_W{1'b1}} ;

assign rplc_data_cen1    = rplc_rsp & info_rplc_way;
assign rplc_data_wen1    = 1'b1                ;
assign rplc_data_addr1   = core_index          ;
assign rplc_data_wdata1  = rplc_rsp_data       ;
assign rplc_data_wstrb1  = {`SRAM_WSTRB_W{1'b1}} ;
                  
assign rplc_tag_cen0     = rplc_rsp &  ~info_rplc_way;
assign rplc_tag_wen0     = 1'b1      ;
assign rplc_tag_addr0    = core_index;
assign rplc_tag_wdata0   = core_tag  ;

assign rplc_tag_cen1     = rplc_rsp & info_rplc_way; 
assign rplc_tag_wen1     = 1'b1      ;
assign rplc_tag_addr1    = core_index;
assign rplc_tag_wdata1   = core_tag  ;
                       
assign rplc_dirty_wen0    =  rplc_rsp &  ~info_rplc_way;
assign rplc_dirty_waddr0  =  core_index ;
assign rplc_dirty_wdata0  =  1'b0       ;

assign rplc_dirty_wen1    =  rplc_rsp & info_rplc_way ;
assign rplc_dirty_waddr1  =  core_index ;
assign rplc_dirty_wdata1  =  1'b0       ;
                       
assign rplc_value_wen0    =  rplc_rsp & ~info_rplc_way ;
assign rplc_value_waddr0  =  core_index ;
assign rplc_value_wdata0  =  1'b1       ;

assign rplc_value_wen1    =  rplc_rsp & info_rplc_way ;
assign rplc_value_waddr1  =  core_index ;
assign rplc_value_wdata1  =  1'b1       ;

endmodule

