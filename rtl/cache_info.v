`include "global_config.v"
`include "cache_define.v"

module cache_info (
  input   wire                        clk                      ,
  input   wire                        reset                    ,

  input   wire                        core_cen                 ,
  input   wire  [`CACHE_INDEX_W-1:0]  core_index               ,
  input   wire  [`CACHE_TAG_W-1:0]    core_tag                 ,
  input   wire                        core_rsp                 ,

  output  wire                        info_rsp                 ,
  output  wire                        info_arb                 ,

  output  wire                        info_hit                 ,
  output  wire                        info_hit_way             ,
  output  wire  [`SRAM_DATA_W-1:0]    info_hit_data            ,

  output  wire                        info_miss                ,
  output  wire                        info_rplc_way            ,
  output  wire                        info_rplc_dirty          ,
  output  wire  [`SRAM_DATA_W-1:0]    info_rplc_data           ,
  output  wire  [`SRAM_TAG_W-1:0]     info_rplc_tag            ,

  output  wire                        info_data_cen0           ,
  output  wire                        info_data_wen0           ,
  output  wire  [`SRAM_ADDR_W-1:0]    info_data_addr0          ,
  input   wire  [`SRAM_DATA_W-1:0]    info_data_rdata0         ,

  output  wire                        info_data_cen1           ,
  output  wire                        info_data_wen1           ,
  output  wire  [`SRAM_ADDR_W-1:0]    info_data_addr1          ,
  input   wire  [`SRAM_DATA_W-1:0]    info_data_rdata1         ,

  output  wire                        info_tag_cen0            ,
  output  wire                        info_tag_wen0            ,
  output  wire  [`SRAM_ADDR_W-1:0]    info_tag_addr0           ,
  input   wire  [`SRAM_TAG_W-1:0]     info_tag_rdata0          ,

  output  wire                        info_tag_cen1            ,
  output  wire                        info_tag_wen1            ,
  output  wire  [`SRAM_ADDR_W-1:0]    info_tag_addr1           ,
  input   wire  [`SRAM_TAG_W-1:0]     info_tag_rdata1          ,

  output  wire  [`CACHE_INDEX_W-1:0]  info_dirty_raddr0        ,
  input   wire                        info_dirty_rdata0        ,
  output  wire  [`CACHE_INDEX_W-1:0]  info_dirty_raddr1        ,
  input   wire                        info_dirty_rdata1        ,

  output  wire  [`CACHE_INDEX_W-1:0]  info_value_raddr0        ,
  input   wire                        info_value_rdata0        ,
  output  wire  [`CACHE_INDEX_W-1:0]  info_value_raddr1        ,
  input   wire                        info_value_rdata1        ,

  output  wire  [`CACHE_INDEX_W-1:0]  info_lru_raddr           ,
  input   wire                        info_lru_rdata              
);

  wire  core_cen_delay;
  dff core_cen_dealy_dff(clk, reset, 1'b1, core_cen, core_cen_delay);
  wire    info_req1 = core_cen & ~core_cen_delay;

  wire  core_req_end = core_cen & core_rsp ;
  wire  core_req_end_delay;
  dff core_req_end_dff(clk, reset, 1'b1, core_req_end, core_req_end_delay);
  wire  info_req2 = core_req_end_delay & core_cen ;
  wire  info_req = info_req1 | info_req2 ;

  assign  info_arb = info_req ;

  assign  info_data_cen0  = info_req;
  assign  info_data_wen0  = 'b0 ;
  assign  info_data_addr0 = core_index;

  assign  info_data_cen1  = info_req;
  assign  info_data_wen1  = 'b0 ;
  assign  info_data_addr1 = core_index;

  assign  info_tag_cen0   = info_req;
  assign  info_tag_wen0   = 'b0 ;
  assign  info_tag_addr0  = core_index;

  assign  info_tag_cen1   = info_req;
  assign  info_tag_wen1   = 'b0 ;
  assign  info_tag_addr1  = core_index;

  assign  info_value_raddr0 = core_index;
  assign  info_value_raddr1 = core_index;
  assign  info_dirty_raddr0 = core_index;
  assign  info_dirty_raddr1 = core_index;
  assign  info_lru_raddr    = core_index;

  wire  read_info_valid; // sram return the valid information
  dff read_info_valid_dff(clk, reset, 1'b1, info_req, read_info_valid);
  dff info_valid_dff(clk, reset, 1'b1, read_info_valid, info_rsp);

  wire  hit0 = ( info_tag_rdata0 == core_tag ) & info_value_rdata0 ;
  wire  hit1 = ( info_tag_rdata1 == core_tag ) & info_value_rdata1 ;

  wire  info_hit_in             =  hit0 | hit1   ;
  wire  info_hit_way_in         = ~hit0 &  hit1  ;
  wire  info_miss_in            = ~hit0 & ~hit1  ;
  wire  info_rplc_way_in        = ~info_lru_rdata;
  wire  info_rplc_dirty_in  =  info_lru_rdata ? info_dirty_rdata0 : info_dirty_rdata1 ;  
  wire  [`CACHE_DATA_W-1:0] info_hit_data_in = ( {`CACHE_DATA_W{hit0}} & info_data_rdata0 ) |
                                               ( {`CACHE_DATA_W{hit1}} & info_data_rdata1 ) ;
  wire  [`CACHE_DATA_W-1:0] info_rplc_data_in = info_lru_rdata ? info_data_rdata0 : info_data_rdata1 ; 
  wire  [`CACHE_TAG_W-1:0]  info_rplc_tag_in  = info_lru_rdata ? info_tag_rdata0  : info_tag_rdata1  ; 
                                                                                                                    
  dff info_hit_dff (clk, reset, read_info_valid, info_hit_in, info_hit ) ;           
  dff info_hit_way_dff (clk, reset, read_info_valid, info_hit_way_in, info_hit_way ) ;       
  dff info_miss_dff (clk, reset, read_info_valid, info_miss_in, info_miss ) ;          
  dff info_rplc_way_dff (clk, reset, read_info_valid, info_rplc_way_in, info_rplc_way ) ;      
  dff info_rplc_dirty_dff (clk, reset, read_info_valid, info_rplc_dirty_in, info_rplc_dirty ) ;
  dff #(`CACHE_DATA_W) info_hit_data_dff(clk, reset, read_info_valid, info_hit_data_in, info_hit_data ) ;
  dff #(`CACHE_DATA_W) info_rplc_data_dff (clk, reset, read_info_valid, info_rplc_data_in, info_rplc_data ) ; 
  dff #(`CACHE_TAG_W)  info_rplc_tag_dff (clk, reset, read_info_valid, info_rplc_tag_in, info_rplc_tag ) ;  

endmodule

