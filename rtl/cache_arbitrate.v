`include "global_config.v"
`include "cache_define.v"

module cache_arbitrate(
  input   wire                        info_arb        ,
  input   wire                        rplc_arb        ,
  input   wire                         rsp_arb        ,

  input   wire                        info_data_cen0  ,
  input   wire                        rplc_data_cen0  ,
  input   wire                         rsp_data_cen0  ,
  output  wire                        sram_data_cen0  ,

  input   wire                        info_data_wen0  ,
  input   wire                        rplc_data_wen0  ,
  input   wire                         rsp_data_wen0  ,
  output  wire                        sram_data_wen0  ,

  input   wire  [`CACHE_INDEX_W-1:0]  info_data_addr0 ,
  input   wire  [`CACHE_INDEX_W-1:0]  rplc_data_addr0 ,
  input   wire  [`CACHE_INDEX_W-1:0]   rsp_data_addr0 ,
  output  wire  [`CACHE_INDEX_W-1:0]  sram_data_addr0 ,

  input   wire  [`SRAM_WSTRB_W-1:0]   rplc_data_wstrb0,
  input   wire  [`SRAM_WSTRB_W-1:0]    rsp_data_wstrb0,
  output  wire  [`SRAM_WSTRB_W-1:0]   sram_data_wstrb0,

  input   wire  [`CACHE_DATA_W-1:0]   rplc_data_wdata0,
  input   wire  [`CACHE_DATA_W-1:0]    rsp_data_wdata0,
  output  wire  [`CACHE_DATA_W-1:0]   sram_data_wdata0,

  input   wire  [`CACHE_DATA_W-1:0]   sram_data_rdata0,
  output  wire  [`CACHE_DATA_W-1:0]   info_data_rdata0,

  input   wire                        info_data_cen1  ,
  input   wire                        rplc_data_cen1  ,
  input   wire                         rsp_data_cen1  ,
  output  wire                        sram_data_cen1  ,

  input   wire                        info_data_wen1  ,
  input   wire                        rplc_data_wen1  ,
  input   wire                         rsp_data_wen1  ,
  output  wire                        sram_data_wen1  ,

  input   wire  [`CACHE_INDEX_W-1:0]  info_data_addr1 ,
  input   wire  [`CACHE_INDEX_W-1:0]  rplc_data_addr1 ,
  input   wire  [`CACHE_INDEX_W-1:0]   rsp_data_addr1 ,
  output  wire  [`CACHE_INDEX_W-1:0]  sram_data_addr1 ,

  input   wire  [`SRAM_WSTRB_W-1:0]   rplc_data_wstrb1,
  input   wire  [`SRAM_WSTRB_W-1:0]    rsp_data_wstrb1,
  output  wire  [`SRAM_WSTRB_W-1:0]   sram_data_wstrb1,

  input   wire  [`CACHE_DATA_W-1:0]   rplc_data_wdata1,
  input   wire  [`CACHE_DATA_W-1:0]    rsp_data_wdata1,
  output  wire  [`CACHE_DATA_W-1:0]   sram_data_wdata1,

  input   wire  [`CACHE_DATA_W-1:0]   sram_data_rdata1,
  output  wire  [`CACHE_DATA_W-1:0]   info_data_rdata1,

  input   wire                        info_tag_cen0  ,
  input   wire                        rplc_tag_cen0  ,
  output  wire                        sram_tag_cen0  ,

  input   wire                        info_tag_wen0  ,
  input   wire                        rplc_tag_wen0  ,
  output  wire                        sram_tag_wen0  ,

  input   wire  [`CACHE_INDEX_W-1:0]  info_tag_addr0 ,
  input   wire  [`CACHE_INDEX_W-1:0]  rplc_tag_addr0 ,
  output  wire  [`CACHE_INDEX_W-1:0]  sram_tag_addr0 ,

  input   wire  [`CACHE_TAG_W-1:0]    rplc_tag_wdata0,
  output  wire  [`CACHE_TAG_W-1:0]    sram_tag_wdata0,

  output  wire  [`CACHE_TAG_W-1:0]    info_tag_rdata0,
  input   wire  [`CACHE_TAG_W-1:0]    sram_tag_rdata0,

  input   wire                        info_tag_cen1  ,
  input   wire                        rplc_tag_cen1  ,
  output  wire                        sram_tag_cen1  ,

  input   wire                        info_tag_wen1  ,
  input   wire                        rplc_tag_wen1  ,
  output  wire                        sram_tag_wen1  ,

  input   wire  [`CACHE_INDEX_W-1:0]  info_tag_addr1 ,
  input   wire  [`CACHE_INDEX_W-1:0]  rplc_tag_addr1 ,
  output  wire  [`CACHE_INDEX_W-1:0]  sram_tag_addr1 ,

  input   wire  [`CACHE_TAG_W-1:0]   rplc_tag_wdata1,
  output  wire  [`CACHE_TAG_W-1:0]   sram_tag_wdata1,

  output  wire  [`CACHE_TAG_W-1:0]   info_tag_rdata1,
  input   wire  [`CACHE_TAG_W-1:0]   sram_tag_rdata1,

  input   wire  [`CACHE_INDEX_W-1:0]  info_dirty_raddr0 ,
  output  wire  [`CACHE_INDEX_W-1:0]   reg_dirty_raddr0 ,

  input   wire                         reg_dirty_rdata0 ,
  output  wire                        info_dirty_rdata0 ,

  input   wire  [`CACHE_INDEX_W-1:0]  info_dirty_raddr1 ,
  output  wire  [`CACHE_INDEX_W-1:0]   reg_dirty_raddr1 ,

  input   wire                         reg_dirty_rdata1 ,
  output  wire                        info_dirty_rdata1 ,

  input   wire  [`CACHE_INDEX_W-1:0]  info_value_raddr0 ,
  output  wire  [`CACHE_INDEX_W-1:0]   reg_value_raddr0 ,

  input   wire                         reg_value_rdata0 ,
  output  wire                        info_value_rdata0 ,

  input   wire  [`CACHE_INDEX_W-1:0]  info_value_raddr1 ,
  output  wire  [`CACHE_INDEX_W-1:0]   reg_value_raddr1 ,

  input   wire                         reg_value_rdata1 ,
  output  wire                        info_value_rdata1 ,

  input   wire  [`CACHE_INDEX_W-1:0]  info_lru_raddr    ,
  output  wire  [`CACHE_INDEX_W-1:0]   reg_lru_raddr    ,

  input   wire                         reg_lru_rdata    ,
  output  wire                        info_lru_rdata    ,

  input   wire                        rplc_dirty_wen0   ,
  input   wire                         rsp_dirty_wen0   ,
  output  wire                         reg_dirty_wen0   ,

  input   wire  [`CACHE_INDEX_W-1:0]  rplc_dirty_waddr0 ,
  input   wire  [`CACHE_INDEX_W-1:0]   rsp_dirty_waddr0 ,
  output  wire  [`CACHE_INDEX_W-1:0]   reg_dirty_waddr0 ,

  input   wire                        rplc_dirty_wdata0 ,
  input   wire                         rsp_dirty_wdata0 ,
  output  wire                         reg_dirty_wdata0 ,

  input   wire                        rplc_dirty_wen1   ,
  input   wire                         rsp_dirty_wen1   ,
  output  wire                         reg_dirty_wen1   ,

  input   wire  [`CACHE_INDEX_W-1:0]  rplc_dirty_waddr1 ,
  input   wire  [`CACHE_INDEX_W-1:0]   rsp_dirty_waddr1 ,
  output  wire  [`CACHE_INDEX_W-1:0]   reg_dirty_waddr1 ,

  input   wire                        rplc_dirty_wdata1 ,
  input   wire                         rsp_dirty_wdata1 ,
  output  wire                         reg_dirty_wdata1 ,

  input   wire                        rplc_value_wen0   ,
  output  wire                         reg_value_wen0   , 

  input   wire                        rplc_value_wen1   ,
  output  wire                        reg_value_wen1    ,

  input   wire  [`CACHE_INDEX_W-1:0]  rplc_value_waddr0 ,
  output  wire  [`CACHE_INDEX_W-1:0]  reg_value_waddr0  ,

  input   wire  [`CACHE_INDEX_W-1:0]  rplc_value_waddr1 ,
  output  wire  [`CACHE_INDEX_W-1:0]  reg_value_waddr1  ,

  input   wire                        rplc_value_wdata0 ,
  output  wire                        reg_value_wdata0  ,

  input   wire                        rplc_value_wdata1 ,
  output  wire                        reg_value_wdata1  ,

  input   wire                        rsp_lru_wen       ,
  output  wire                        reg_lru_wen       ,

  input   wire  [`CACHE_INDEX_W-1:0]  rsp_lru_waddr     ,
  output  wire  [`CACHE_INDEX_W-1:0]  reg_lru_waddr     ,

  input   wire                        rsp_lru_wdata     ,
  output  wire                        reg_lru_wdata      

);

  assign sram_data_cen0 = ( info_arb & info_data_cen0 ) |
                          ( rplc_arb & rplc_data_cen0 ) |
                          (  rsp_arb &  rsp_data_cen0 ) ;

  assign sram_data_wen0 = ( info_arb & info_data_wen0 ) |
                          ( rplc_arb & rplc_data_wen0 ) |
                          (  rsp_arb &  rsp_data_wen0 ) ;

  assign sram_data_addr0 = ( {`CACHE_INDEX_W{info_arb}} & info_data_addr0 ) |
                           ( {`CACHE_INDEX_W{rplc_arb}} & rplc_data_addr0 ) |
                           ( {`CACHE_INDEX_W{ rsp_arb}} &  rsp_data_addr0 ) ;

  assign sram_data_wstrb0 = ( {`SRAM_WSTRB_W{rplc_arb}} & rplc_data_wstrb0 ) |
                            ( {`SRAM_WSTRB_W{ rsp_arb}} &  rsp_data_wstrb0 ) ;

  assign sram_data_wdata0 = ( {`SRAM_DATA_W{rplc_arb}} & rplc_data_wdata0 ) |
                            ( {`SRAM_DATA_W{ rsp_arb}} &  rsp_data_wdata0 ) ;

  assign info_data_rdata0 = sram_data_rdata0;

  assign sram_data_cen1 = ( info_arb & info_data_cen1 ) |
                          ( rplc_arb & rplc_data_cen1 ) |
                          (  rsp_arb &  rsp_data_cen1 ) ;

  assign sram_data_wen1 = ( info_arb & info_data_wen1 ) |
                          ( rplc_arb & rplc_data_wen1 ) |
                          (  rsp_arb &  rsp_data_wen1 ) ;

  assign sram_data_addr1 = ( {`CACHE_INDEX_W{info_arb}} & info_data_addr1 ) |
                           ( {`CACHE_INDEX_W{rplc_arb}} & rplc_data_addr1 ) |
                           ( {`CACHE_INDEX_W{ rsp_arb}} &  rsp_data_addr1 ) ;

  assign sram_data_wstrb1 = ( {`SRAM_WSTRB_W{rplc_arb}} & rplc_data_wstrb1 ) |
                            ( {`SRAM_WSTRB_W{ rsp_arb}} &  rsp_data_wstrb1 ) ;

  assign sram_data_wdata1 = ( {`CACHE_DATA_W{rplc_arb}} & rplc_data_wdata1 ) |
                            ( {`CACHE_DATA_W{ rsp_arb}} &  rsp_data_wdata1 ) ;

  assign info_data_rdata1 = sram_data_rdata1 ;

  assign  sram_tag_cen0 = ( info_arb & info_tag_cen0 ) |
                         ( rplc_arb & rplc_tag_cen0 ) ;

  assign  sram_tag_wen0 = ( info_arb & info_tag_wen0 ) |
                         ( rplc_arb & rplc_tag_wen0 ) ;

  assign  sram_tag_addr0 = ( {`CACHE_INDEX_W{info_arb}} & info_tag_addr0 ) |
                           ( {`CACHE_INDEX_W{rplc_arb}} & rplc_tag_addr0 ) ;

  assign  sram_tag_wdata0 = rplc_tag_wdata0 ;

  assign  info_tag_rdata0 = sram_tag_rdata0 ;

  assign  sram_tag_cen1 = ( info_arb & info_tag_cen1 ) |
                          ( rplc_arb & rplc_tag_cen1 ) ;

  assign  sram_tag_wen1 = ( info_arb & info_tag_wen1 ) |
                         ( rplc_arb & rplc_tag_wen1 ) ;

  assign  sram_tag_addr1 = ( {`CACHE_INDEX_W{info_arb}} & info_tag_addr1 ) |
                           ( {`CACHE_INDEX_W{rplc_arb}} & rplc_tag_addr1 ) ;

  assign  sram_tag_wdata1 = rplc_tag_wdata1 ;

  assign  info_tag_rdata1 = sram_tag_rdata1 ;

  assign  reg_dirty_raddr0 = info_dirty_raddr0 ;

  assign  info_dirty_rdata0 = reg_dirty_rdata0 ;

  assign reg_dirty_raddr1 = info_dirty_raddr1 ;

  assign info_dirty_rdata1 = reg_dirty_rdata1 ;

  assign  reg_value_raddr0 = info_value_raddr0 ;

  assign info_value_rdata0 = reg_value_rdata0 ;

  assign reg_value_raddr1 =  info_value_raddr1 ;

  assign info_value_rdata1 = reg_value_rdata1 ;

  assign reg_lru_raddr =  info_lru_raddr ;

  assign info_lru_rdata = reg_lru_rdata ;

  assign reg_dirty_wen0  =  ( rplc_arb &  rplc_dirty_wen0 ) |
                            (  rsp_arb &   rsp_dirty_wen0 ) ;

  assign  reg_dirty_waddr0  = ( {`CACHE_INDEX_W{rplc_arb}} & rplc_dirty_waddr0 ) | 
                              ( {`CACHE_INDEX_W{ rsp_arb}} &  rsp_dirty_waddr0 ) ;

  assign reg_dirty_wdata0  =  ( rplc_arb &  rplc_dirty_wdata0 ) |
                              (  rsp_arb &   rsp_dirty_wdata0 ) ;

  assign reg_dirty_wen1 = ( rplc_arb &  rplc_dirty_wen1 ) |
                          (  rsp_arb &   rsp_dirty_wen1 ) ;

  assign reg_dirty_waddr1 = ( {`CACHE_INDEX_W{rplc_arb}} & rplc_dirty_waddr1 ) |
                            ( {`CACHE_INDEX_W{ rsp_arb}} &  rsp_dirty_waddr1 ) ;

  assign reg_dirty_wdata1 = ( rplc_arb & rplc_dirty_wdata1 ) | 
                            (  rsp_arb &  rsp_dirty_wdata1 ) ;

  assign reg_value_wen0 =  rplc_value_wen0 ;

  assign reg_value_wen1 =  rplc_value_wen1 ;

  assign  reg_value_waddr0 =  rplc_value_waddr0 ;

  assign reg_value_waddr1 =  rplc_value_waddr1 ;

  assign reg_value_wdata0 =  rplc_value_wdata0 ;

  assign reg_value_wdata1 =  rplc_value_wdata1 ;

  assign reg_lru_wen   = rsp_lru_wen   ;

  assign reg_lru_waddr = rsp_lru_waddr ; 

  assign reg_lru_wdata = rsp_lru_wdata ;

endmodule
