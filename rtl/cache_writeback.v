`include "cache_wb_def.v"

module cache_writeback(
  input   wire                        clk               ,
  input   wire                        reset             ,

  input   wire                        info_rsp          ,
  input   wire                        info_miss         ,
  input   wire                        info_rplc_dirty   ,
  input   wire  [`SRAM_DATA_W-1:0]    info_rplc_data    ,
  input   wire  [`CACHE_TAG_W-1:0]    info_rplc_tag     ,

  input   wire  [`CACHE_INDEX_W-1:0]  core_index        ,

  output  wire                    wb_rsp          ,
                                                    
  output  wire  [`AxID_W-1:0]     wb_awid         ,
  output  wire  [`AxADDR_W-1:0]   wb_awaddr       ,
  output  wire  [`AxLEN_W-1:0]    wb_awlen        ,
  output  wire  [`AxSIZE_W-1:0]   wb_awsize       ,
  output  wire  [`AxBURST_W-1:0]  wb_awburst      ,
  output  wire                    wb_awlock       ,
  output  wire  [`AxCACHE_W-1:0]  wb_awcache      ,
  output  wire  [`AxPORT_W-1:0]   wb_awport       ,
  output  wire  [`AxQOS_W-1:0]    wb_awqos        ,
  output  wire  [`AxREGION_W-1:0] wb_awregion     ,
  //output  wire  [`AxUSER_W-1:0] wb_awuser       ,
  output  wire                    wb_awvalid      ,
  input   wire                    wb_awready      ,
                                                  
  output  wire  [`AxID_W-1:0]     wb_wid          ,
  output  wire  [`AxDATA_W-1:0]   wb_wdata        ,
  output  wire  [`AxWSTRB_W-1:0]  wb_wstrb        ,
  output  wire                    wb_wlast        ,
  //output  wire  [`AxUSER_W-1:0] wb_wuser        ,
  output  wire                    wb_wvalid       ,
  input   wire                    wb_wready       , 
                                                   
  input   wire  [`AxID_W-1:0]     wb_bid          ,
  input   wire  [`AxRESP_W-1:0]   wb_bresp        ,
  //input   wire  [`AxUSER_W-1:0] wb_buser        ,
  input   wire                    wb_bvalid       ,
  output  wire                    wb_bready           
);

  wire  wb_req = info_rsp & info_miss & info_rplc_dirty ;

  wire  [`AxDATA_W-1:0] wb_wdata_in[`CACHE_DATA_N-1:0] ;
  genvar i;
  generate
    for(i=0; i<`CACHE_DATA_N; i=i+1) begin
      assign  wb_wdata_in[i] = info_rplc_data[(i+1)*`AxDATA_W-1 : i*`AxDATA_W] ;
    end
  endgenerate

  wire  [`AxADDR_W-1:0] wb_awaddr_in = { info_rplc_tag, core_index, {`CACHE_OFFSET_W{1'b0}} , {$clog2(`CORE_DATA_W/8){1'b0}} } ;

  wire  wb_awvalid_en = wb_req | (wb_awvalid & wb_awready) ;
  wire  wb_awvalid_in = ( wb_req & 1'b1 ) |
                        ( wb_awvalid & wb_awready & 1'b0 ) ;

  assign  wb_awid     = `WB_AWID      ;
  dff #(`AxADDR_W)wb_awaddr_dff(clk, reset, wb_req, wb_awaddr_in, wb_awaddr);
  assign  wb_awlen    = `WB_AWLEN     ;
  assign  wb_awsize   = `WB_AWSIZE    ;
  assign  wb_awburst  = `WB_AWBURST   ;
  assign  wb_awlock   = `WB_AWLOCK    ;
  assign  wb_awcache  = `WB_AWCACHE   ;
  assign  wb_awport   = `WB_AWPORT    ;
  assign  wb_awqos    = `WB_AWQOS     ;
  assign  wb_awregion = `WB_AWREGION  ;
  dff wb_awvalid_dff(clk, reset, wb_awvalid_en, wb_awvalid_in, wb_awvalid );

  reg  [`CACHE_OFFSET_W-1:0] wcount;
  always@(posedge clk) begin
    if(reset == `RESET_ENABLE)
      wcount = 'b0;
    else if(wb_rsp)
      wcount = 'b0;
    else if ((wb_wvalid & wb_wready) || wb_req )
      wcount = wcount + 1'b1 ;
  end

  assign  wb_wid = `WB_WID  ;
  wire  wb_wdata_en = wb_req | ( wb_wvalid & wb_wready ) ;
  dff #(`AxDATA_W)wb_wdata_dff(clk, reset, wb_wdata_en, wb_wdata_in[wcount], wb_wdata);
  assign wb_wstrb = ({`AxWSTRB_W{1'b1}});
  assign wb_wlast = ( wcount == {`CACHE_OFFSET_W{1'b0}} ) && wb_wvalid ;

  wire wb_wvalid_in = ( wb_req & 1'b1 ) |
                      ( wb_wvalid & wb_wready & wb_wlast & 1'b0 ) ;

  wire  wb_wvalid_en = wb_req | ( wb_wvalid & wb_wready & wb_wlast ) ;
  dff wb_wvalid_dff(clk, reset, wb_wvalid_en, wb_wvalid_in, wb_wvalid);

  assign  wb_rsp = wb_bvalid & wb_bready & (wb_bid==`WB_BID) & (wb_bresp==`WB_BRESP) ;
  assign  wb_bready = 1'b1;

endmodule

