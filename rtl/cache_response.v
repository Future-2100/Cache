`include "global_config.v"
`include "cache_define.v"

module cache_response (
  input   wire                            clk               ,
  input   wire                            reset             ,

  input   wire    [`CACHE_INDEX_W-1:0]    core_index        ,
  input   wire    [`CACHE_OFFSET_W-1:0]   core_offset       ,
  input   wire                            core_wen          ,
  input   wire    [`CORE_WSTRB_W-1:0]     core_wstrb        ,
  input   wire    [`CORE_DATA_W-1:0]      core_wdata        ,

  input   wire                            info_rsp          ,
  input   wire                            info_hit          ,
  input   wire                            info_hit_way      ,
  input   wire    [`SRAM_DATA_W-1:0]      info_hit_data     ,

  input   wire                            rplc_rsp          ,
  input   wire    [`SRAM_DATA_W-1:0]      rplc_rsp_data     ,
  input   wire                            info_rplc_way     ,

  output  wire                            core_rsp          ,
  output  wire    [`CORE_DATA_W-1:0]      core_rdata        ,

  output  wire                            rsp_arb           ,

  output  wire                            rsp_dirty_wen0    ,
  output  wire    [`SRAM_ADDR_W-1:0]      rsp_dirty_waddr0  ,
  output  wire                            rsp_dirty_wdata0  ,

  output  wire                            rsp_dirty_wen1    ,
  output  wire    [`SRAM_ADDR_W-1:0]      rsp_dirty_waddr1  ,
  output  wire                            rsp_dirty_wdata1  ,
  
  output  wire                            rsp_lru_wen       ,
  output  wire    [`SRAM_ADDR_W-1:0]      rsp_lru_waddr     ,
  output  wire                            rsp_lru_wdata     ,

  output  wire                            rsp_data_cen0     ,
  output  wire                            rsp_data_wen0     ,
  output  wire    [`SRAM_ADDR_W-1:0]      rsp_data_addr0    ,
  output  wire    [`SRAM_DATA_W-1:0]      rsp_data_wdata0   ,
  output  wire    [`SRAM_WSTRB_W-1:0]     rsp_data_wstrb0   , 

  output  wire                            rsp_data_cen1     ,
  output  wire                            rsp_data_wen1     ,
  output  wire    [`SRAM_ADDR_W-1:0]      rsp_data_addr1    ,
  output  wire    [`SRAM_DATA_W-1:0]      rsp_data_wdata1   ,
  output  wire    [`SRAM_WSTRB_W-1:0]     rsp_data_wstrb1  

);

  wire  core_rsp_in =  (info_rsp & info_hit) | rplc_rsp ;
  dff core_rsp_dff(clk, reset, 1'b1, core_rsp_in, core_rsp);

  //{ core_rdata : select the 64bits rdata from 512bits 
  wire  [`SRAM_DATA_W-1:0]  select_rdata = ( {`SRAM_DATA_W{(info_rsp & info_hit)}} & info_hit_data ) |
                                           ( {`SRAM_DATA_W{ rplc_rsp            }} & rplc_rsp_data ) ;

  wire  [`CORE_DATA_W-1:0] split_rdata[`CACHE_DATA_N-1:0] ;
  genvar i;
  generate
    for(i=0; i<`CACHE_DATA_N; i=i+1) begin
      assign split_rdata[i] = select_rdata[(i+1)*`CORE_DATA_W-1:i*`CORE_DATA_W];
    end
  endgenerate

  wire  [`CORE_DATA_W-1:0]  core_rdata_in = split_rdata[core_offset] ;
  dff #(`CORE_DATA_W) core_rdata_dff(clk, reset, 1'b1, core_rdata_in, core_rdata);
  // end of core_rdata }


  wire rsp_arb_in = core_wen & (( info_rsp & info_hit ) | ( rplc_rsp )) ;
  dff rsp_arb_dff(clk, reset, 1'b1, rsp_arb_in, rsp_arb);

  wire  rsp_data_cen0_in= (( info_rsp & info_hit & info_hit_way==0 ) | (rplc_rsp & info_rplc_way==0)) & core_wen ;
  dff rsp_data_cen0_dff(clk, reset, 1'b1, rsp_data_cen0_in, rsp_data_cen0 );
  dff rsp_data_wen0_dff(clk, reset, 1'b1, rsp_data_cen0_in, rsp_data_wen0 );

  wire  rsp_data_cen1_in = (( info_rsp & info_hit & info_hit_way ) | (rplc_rsp & info_rplc_way)) & core_wen ;
  dff rsp_data_cen1_dff(clk, reset, 1'b1, rsp_data_cen1_in, rsp_data_cen1 );
  dff rsp_data_wen1_dff(clk, reset, 1'b1, rsp_data_cen1_in, rsp_data_wen1 );

  // { rsp_sram_wstrb
  wire  [`CORE_WSTRB_W-1:0] split_wstrb    [`CACHE_DATA_N-1:0] ;
  wire  [`CORE_WSTRB_W-1:0] split_wstrb_in [`CACHE_DATA_N-1:0] ;

  generate
    for(i=0; i<`CACHE_DATA_N; i=i+1) begin
      assign split_wstrb_in[i] = (core_offset == i) ? core_wstrb : {`CORE_WSTRB_W{1'b0}} ;
      dff #(`CORE_WSTRB_W)split_wstrb_dff(clk, reset, 1'b1, split_wstrb_in[i],split_wstrb[i]);
      assign  rsp_data_wstrb0[(i+1)*`CORE_WSTRB_W-1 : i*`CORE_WSTRB_W] = split_wstrb[i] ;
    end
  endgenerate
  assign rsp_data_wstrb1 = rsp_data_wstrb0 ;
  // end of rsp_sram0_wstrb }

  // { rsp_sram0_wdata
  wire  [`CORE_DATA_W-1:0]  split_wdata [`CACHE_DATA_N-1:0];
  wire  [`CORE_DATA_W-1:0]  split_wdata_in [`CACHE_DATA_N-1:0];

  generate
    for(i=0; i<`CACHE_DATA_N; i=i+1) begin
      assign  split_wdata_in[i] = (core_offset == i) ? core_wdata : {`CORE_DATA_W{1'b1}} ;
      dff #(`CORE_DATA_W)split_wdata_dff(clk, reset, 1'b1, split_wdata_in[i], split_wdata[i]);
      assign rsp_data_wdata0[(i+1)*`CORE_DATA_W-1:i*`CORE_DATA_W] = split_wdata[i];
    end
  endgenerate
  assign rsp_data_wdata1 = rsp_data_wdata0;
  // end of rsp_sram0_wdata }

  wire  [`SRAM_ADDR_W-1:0]  rsp_data_addr0_in = core_index;
  dff #(`SRAM_ADDR_W) rsp_data_addr0_dff(clk, reset, 1'b1, rsp_data_addr0_in, rsp_data_addr0);
  assign rsp_data_addr1 = rsp_data_addr0 ;

  assign rsp_dirty_wen0 = rsp_data_wen0 ;
  assign rsp_dirty_wen1 = rsp_data_wen1 ;
                         
  assign rsp_dirty_waddr0 = rsp_data_addr0 ;
  assign rsp_dirty_waddr1 = rsp_data_addr1 ;
  assign rsp_dirty_wdata0 = 1'b1 ;
  assign rsp_dirty_wdata1 = 1'b1 ;
                   
  assign rsp_lru_wen    = core_rsp    ; 
  assign rsp_lru_waddr  = rsp_data_addr0 ;
  wire rsp_lru_wdata_in = ( info_rsp & info_hit & info_hit_way ) | ( rplc_rsp & info_rplc_way );
  dff rsp_lru_wdata_dff(clk, reset, 1'b1, rsp_lru_wdata_in, rsp_lru_wdata);
  
endmodule

