`include "global_config.v"
`include "cache_define.v"
`include "axi_define.v"

module cache_top(
  input   wire                            clk            ,
  input   wire                            reset          ,

  input   wire                            core_cen       ,
  input   wire                            core_wen       ,
  input   wire    [`CORE_ADDR_W-1:0]      core_addr      ,
  input   wire    [`CORE_DATA_W-1:0]      core_wdata     ,
  input   wire    [`CORE_WSTRB_W-1:0]     core_wstrb     ,

  output  wire                            core_rsp       ,
  output  wire    [`CORE_DATA_W-1:0]      core_rdata     ,

  output  wire    [`AxID_W-1:0]           axi_arid       ,
  output  wire    [`AxADDR_W-1:0]         axi_araddr     ,
  output  wire    [`AxLEN_W-1:0]          axi_arlen      ,
  output  wire    [`AxSIZE_W-1:0]         axi_arsize     ,
  output  wire    [`AxBURST_W-1:0]        axi_arburst    ,
  output  wire                            axi_arlock     ,
  output  wire    [`AxCACHE_W-1:0]        axi_arcache    ,
  output  wire    [`AxPORT_W-1:0]         axi_arport     ,
  output  wire    [`AxQOS_W-1:0]          axi_arqos      ,
  output  wire    [`AxREGION_W-1:0]       axi_arregion   ,
  output  wire                            axi_arvalid    ,
  input   wire                            axi_arready    ,

  input   wire    [`AxID_W-1:0]           axi_rid        ,
  input   wire    [`AxDATA_W-1:0]         axi_rdata      ,
  input   wire    [`AxRESP_W-1:0]         axi_rresp      ,
  input   wire                            axi_rlast      ,
  input   wire                            axi_rvalid     ,
  output  wire                            axi_rready     ,

  output  wire    [`AxID_W-1:0]           axi_awid       ,
  output  wire    [`AxADDR_W-1:0]         axi_awaddr     ,
  output  wire    [`AxLEN_W-1:0]          axi_awlen      ,
  output  wire    [`AxSIZE_W-1:0]         axi_awsize     ,
  output  wire    [`AxBURST_W-1:0]        axi_awburst    ,
  output  wire                            axi_awlock     ,
  output  wire    [`AxCACHE_W-1:0]        axi_awcache    ,
  output  wire    [`AxPORT_W-1:0]         axi_awport     ,
  output  wire    [`AxQOS_W-1:0]          axi_awqos      ,
  output  wire    [`AxREGION_W-1:0]       axi_awregion   ,
  output  wire                            axi_awvalid    ,
  input   wire                            axi_awready    ,

  output  wire    [`AxID_W-1:0]           axi_wid        ,
  output  wire    [`AxDATA_W-1:0]         axi_wdata      ,
  output  wire    [`AxWSTRB_W-1:0]        axi_wstrb      ,
  output  wire                            axi_wlast      ,
  output  wire                            axi_wvalid     ,
  input   wire                            axi_wready     ,

  input   wire    [`AxID_W-1:0]           axi_bid        ,
  input   wire    [`AxRESP_W-1:0]         axi_bresp      ,
  input   wire                            axi_bvalid     ,
  output  wire                            axi_bready       
);

wire [`CACHE_TAG_W-1:0]    core_tag    = core_addr[`CACHE_TAG_LOCAL]    ;
wire [`CACHE_INDEX_W-1:0]  core_index  = core_addr[`CACHE_INDEX_LOCAL]  ;
wire [`CACHE_OFFSET_W-1:0] core_offset = core_addr[`CACHE_OFFSET_LOCAL] ;

wire                        info_arb           ;
wire                        rplc_arb           ;
wire                        rsp_arb            ;

wire                        info_rsp           ;
wire                        info_hit           ;
wire                        info_hit_way       ;
wire  [`SRAM_DATA_W-1:0]    info_hit_data      ;
wire                        info_miss          ;
wire                        info_rplc_way      ;
wire                        info_rplc_dirty    ;
wire  [`SRAM_DATA_W-1:0]    info_rplc_data     ;
wire  [`SRAM_TAG_W-1:0]     info_rplc_tag      ;
wire                        info_data_cen0     ;
wire                        info_data_wen0     ;
wire  [`SRAM_ADDR_W-1:0]    info_data_addr0    ;
wire  [`SRAM_DATA_W-1:0]    info_data_rdata0   ;
wire                        info_data_cen1     ;
wire                        info_data_wen1     ;
wire  [`SRAM_ADDR_W-1:0]    info_data_addr1    ;
wire  [`SRAM_DATA_W-1:0]    info_data_rdata1   ;
wire                        info_tag_cen0      ;
wire                        info_tag_wen0      ;
wire  [`SRAM_ADDR_W-1:0]    info_tag_addr0     ;
wire  [`SRAM_TAG_W-1:0]     info_tag_rdata0    ;
wire                        info_tag_cen1      ;
wire                        info_tag_wen1      ;
wire  [`SRAM_ADDR_W-1:0]    info_tag_addr1     ;
wire  [`SRAM_TAG_W-1:0]     info_tag_rdata1    ;
wire  [`CACHE_INDEX_W-1:0]  info_dirty_raddr0  ;
wire                        info_dirty_rdata0  ;
wire  [`CACHE_INDEX_W-1:0]  info_dirty_raddr1  ;
wire                        info_dirty_rdata1  ;
wire  [`CACHE_INDEX_W-1:0]  info_value_raddr0  ;
wire                        info_value_rdata0  ;
wire  [`CACHE_INDEX_W-1:0]  info_value_raddr1  ;
wire                        info_value_rdata1  ;
wire  [`CACHE_INDEX_W-1:0]  info_lru_raddr     ;
wire                        info_lru_rdata     ;

cache_info cache_info_inst(
  .clk                ( clk               )      ,
  .reset              ( reset             )      ,
  .core_cen           ( core_cen          )      ,
  .core_index         ( core_index        )      ,
  .core_tag           ( core_tag          )      ,
  .core_rsp           ( core_rsp          )      ,
  .info_arb           ( info_arb          )      ,
  .info_rsp           ( info_rsp          )      ,
  .info_hit           ( info_hit          )      ,
  .info_hit_way       ( info_hit_way      )      ,
  .info_hit_data      ( info_hit_data     )      ,
  .info_miss          ( info_miss         )      ,
  .info_rplc_way      ( info_rplc_way     )      ,
  .info_rplc_dirty    ( info_rplc_dirty   )      ,
  .info_rplc_data     ( info_rplc_data    )      ,
  .info_rplc_tag      ( info_rplc_tag     )      ,
  .info_data_cen0     ( info_data_cen0    )      ,
  .info_data_wen0     ( info_data_wen0    )      ,
  .info_data_addr0    ( info_data_addr0   )      ,
  .info_data_rdata0   ( info_data_rdata0  )      ,
  .info_data_cen1     ( info_data_cen1    )      ,
  .info_data_wen1     ( info_data_wen1    )      ,
  .info_data_addr1    ( info_data_addr1   )      ,
  .info_data_rdata1   ( info_data_rdata1  )      ,
  .info_tag_cen0      ( info_tag_cen0     )      ,
  .info_tag_wen0      ( info_tag_wen0     )      ,
  .info_tag_addr0     ( info_tag_addr0    )      ,
  .info_tag_rdata0    ( info_tag_rdata0   )      ,
  .info_tag_cen1      ( info_tag_cen1     )      ,
  .info_tag_wen1      ( info_tag_wen1     )      ,
  .info_tag_addr1     ( info_tag_addr1    )      ,
  .info_tag_rdata1    ( info_tag_rdata1   )      ,
  .info_dirty_raddr0  ( info_dirty_raddr0 )      ,
  .info_dirty_rdata0  ( info_dirty_rdata0 )      ,
  .info_dirty_raddr1  ( info_dirty_raddr1 )      ,
  .info_dirty_rdata1  ( info_dirty_rdata1 )      ,
  .info_value_raddr0  ( info_value_raddr0 )      ,
  .info_value_rdata0  ( info_value_rdata0 )      ,
  .info_value_raddr1  ( info_value_raddr1 )      ,
  .info_value_rdata1  ( info_value_rdata1 )      ,
  .info_lru_raddr     ( info_lru_raddr    )      ,
  .info_lru_rdata     ( info_lru_rdata    )         
);

  wire  wb_rsp  ;

cache_writeback cache_writeback_inst(
  .clk              ( clk             )  ,
  .reset            ( reset           )  ,
  .info_rsp         ( info_rsp        )  ,
  .info_miss        ( info_miss       )  ,
  .info_rplc_dirty  ( info_rplc_dirty )  ,
  .info_rplc_data   ( info_rplc_data  )  ,
  .info_rplc_tag    ( info_rplc_tag   )  ,
  .core_index       ( core_index      )  ,
  .wb_rsp           ( wb_rsp          )  ,
  .wb_awid          ( axi_awid        )  ,
  .wb_awaddr        ( axi_awaddr      )  ,
  .wb_awlen         ( axi_awlen       )  ,
  .wb_awsize        ( axi_awsize      )  ,
  .wb_awburst       ( axi_awburst     )  ,
  .wb_awlock        ( axi_awlock      )  ,
  .wb_awcache       ( axi_awcache     )  ,
  .wb_awport        ( axi_awport      )  ,
  .wb_awqos         ( axi_awqos       )  ,
  .wb_awregion      ( axi_awregion    )  ,
  .wb_awvalid       ( axi_awvalid     )  ,
  .wb_awready       ( axi_awready     )  ,
  .wb_wid           ( axi_wid         )  ,
  .wb_wdata         ( axi_wdata       )  ,
  .wb_wstrb         ( axi_wstrb       )  ,
  .wb_wlast         ( axi_wlast       )  ,
  .wb_wvalid        ( axi_wvalid      )  ,
  .wb_wready        ( axi_wready      )  , 
  .wb_bid           ( axi_bid         )  ,
  .wb_bresp         ( axi_bresp       )  ,
  .wb_bvalid        ( axi_bvalid      )  ,
  .wb_bready        ( axi_bready      )    
);

  wire  [`SRAM_DATA_W-1:0]    rplc_rsp_data       ;
  wire                        rplc_rsp            ;
  wire                        rplc_data_cen0      ;
  wire                        rplc_data_cen1      ;
  wire                        rplc_data_wen0      ;
  wire                        rplc_data_wen1      ;
  wire  [`SRAM_ADDR_W-1:0]    rplc_data_addr0     ;
  wire  [`SRAM_ADDR_W-1:0]    rplc_data_addr1     ;
  wire  [`SRAM_DATA_W-1:0]    rplc_data_wdata0    ;
  wire  [`SRAM_DATA_W-1:0]    rplc_data_wdata1    ;
  wire  [`SRAM_WSTRB_W-1:0]   rplc_data_wstrb0    ;
  wire  [`SRAM_WSTRB_W-1:0]   rplc_data_wstrb1    ;
  wire                        rplc_tag_cen0       ;
  wire                        rplc_tag_cen1       ;
  wire                        rplc_tag_wen0       ;
  wire                        rplc_tag_wen1       ;
  wire  [`SRAM_ADDR_W-1:0]    rplc_tag_addr0      ;
  wire  [`SRAM_ADDR_W-1:0]    rplc_tag_addr1      ;
  wire  [`SRAM_TAG_W-1:0]     rplc_tag_wdata0     ;
  wire  [`SRAM_TAG_W-1:0]     rplc_tag_wdata1     ;
  wire  [`CACHE_INDEX_W-1:0]  rplc_dirty_waddr0   ;
  wire  [`CACHE_INDEX_W-1:0]  rplc_dirty_waddr1   ;
  wire                        rplc_dirty_wen0     ;
  wire                        rplc_dirty_wen1     ;
  wire                        rplc_dirty_wdata0   ;
  wire                        rplc_dirty_wdata1   ;
  wire  [`CACHE_INDEX_W-1:0]  rplc_value_waddr0   ;
  wire  [`CACHE_INDEX_W-1:0]  rplc_value_waddr1   ;
  wire                        rplc_value_wen0     ;
  wire                        rplc_value_wen1     ;
  wire                        rplc_value_wdata0   ;
  wire                        rplc_value_wdata1   ;

cache_replace cache_replace_inst (
  .clk                 ( clk                  ) ,
  .reset               ( reset                ) ,
  .info_miss           ( info_miss            ) ,
  .info_rplc_way       ( info_rplc_way        ) ,
  .info_rplc_dirty     ( info_rplc_dirty      ) ,
	.info_rsp            ( info_rsp             ) ,
  .wb_rsp              ( wb_rsp               ) ,
  .rplc_arb            ( rplc_arb             ) ,
  .core_index          ( core_index           ) ,
  .core_tag            ( core_tag             ) ,
  .rplc_arid           ( axi_arid             ) ,
  .rplc_araddr         ( axi_araddr           ) ,
  .rplc_arlen          ( axi_arlen            ) ,
  .rplc_arsize         ( axi_arsize           ) ,
  .rplc_arburst        ( axi_arburst          ) ,
  .rplc_arlock         ( axi_arlock           ) ,
  .rplc_arcache        ( axi_arcache          ) ,
  .rplc_arport         ( axi_arport           ) ,
  .rplc_arqos          ( axi_arqos            ) ,
  .rplc_arregion       ( axi_arregion         ) ,
  .rplc_arvalid        ( axi_arvalid          ) ,
  .rplc_arready        ( axi_arready          ) ,
  .rplc_rid            ( axi_rid              ) ,
  .rplc_rdata          ( axi_rdata            ) ,
  .rplc_rresp          ( axi_rresp            ) ,
  .rplc_rlast          ( axi_rlast            ) ,
  .rplc_rvalid         ( axi_rvalid           ) ,
  .rplc_rready         ( axi_rready           ) ,
  .rplc_rsp_data       ( rplc_rsp_data        ) ,
  .rplc_rsp            ( rplc_rsp             ) ,
  .rplc_data_cen0      ( rplc_data_cen0       ) ,
  .rplc_data_cen1      ( rplc_data_cen1       ) ,
  .rplc_data_wen0      ( rplc_data_wen0       ) ,
  .rplc_data_wen1      ( rplc_data_wen1       ) ,
  .rplc_data_addr0     ( rplc_data_addr0      ) ,
  .rplc_data_addr1     ( rplc_data_addr1      ) ,
  .rplc_data_wdata0    ( rplc_data_wdata0     ) ,
  .rplc_data_wdata1    ( rplc_data_wdata1     ) ,
  .rplc_data_wstrb0    ( rplc_data_wstrb0     ) ,
  .rplc_data_wstrb1    ( rplc_data_wstrb1     ) ,
  .rplc_tag_cen0       ( rplc_tag_cen0        ) ,
  .rplc_tag_cen1       ( rplc_tag_cen1        ) ,
  .rplc_tag_wen0       ( rplc_tag_wen0        ) ,
  .rplc_tag_wen1       ( rplc_tag_wen1        ) ,
  .rplc_tag_addr0      ( rplc_tag_addr0       ) ,
  .rplc_tag_addr1      ( rplc_tag_addr1       ) ,
  .rplc_tag_wdata0     ( rplc_tag_wdata0      ) ,
  .rplc_tag_wdata1     ( rplc_tag_wdata1      ) ,
  .rplc_dirty_waddr0   ( rplc_dirty_waddr0    ) ,
  .rplc_dirty_waddr1   ( rplc_dirty_waddr1    ) ,
  .rplc_dirty_wen0     ( rplc_dirty_wen0      ) ,
  .rplc_dirty_wen1     ( rplc_dirty_wen1      ) ,
  .rplc_dirty_wdata0   ( rplc_dirty_wdata0    ) ,
  .rplc_dirty_wdata1   ( rplc_dirty_wdata1    ) ,
  .rplc_value_waddr0   ( rplc_value_waddr0    ) ,
  .rplc_value_waddr1   ( rplc_value_waddr1    ) ,
  .rplc_value_wen0     ( rplc_value_wen0      ) ,
  .rplc_value_wen1     ( rplc_value_wen1      ) ,
  .rplc_value_wdata0   ( rplc_value_wdata0    ) ,
  .rplc_value_wdata1   ( rplc_value_wdata1    ) 
);

wire                            rsp_dirty_wen0   ;
wire    [`SRAM_ADDR_W-1:0]      rsp_dirty_waddr0 ;
wire                            rsp_dirty_wdata0 ;
wire                            rsp_dirty_wen1   ;
wire    [`SRAM_ADDR_W-1:0]      rsp_dirty_waddr1 ;
wire                            rsp_dirty_wdata1 ;
wire                            rsp_lru_wen      ;
wire    [`SRAM_ADDR_W-1:0]      rsp_lru_waddr    ;
wire                            rsp_lru_wdata    ;
wire                            rsp_data_cen0    ;
wire                            rsp_data_wen0    ;
wire    [`SRAM_ADDR_W-1:0]      rsp_data_addr0   ;
wire    [`SRAM_DATA_W-1:0]      rsp_data_wdata0  ;
wire    [`SRAM_WSTRB_W-1:0]     rsp_data_wstrb0  ;
wire                            rsp_data_cen1    ;
wire                            rsp_data_wen1    ;
wire    [`SRAM_ADDR_W-1:0]      rsp_data_addr1   ;
wire    [`SRAM_DATA_W-1:0]      rsp_data_wdata1  ;
wire    [`SRAM_WSTRB_W-1:0]     rsp_data_wstrb1  ;


cache_response cache_response_inst(
  .clk              ( clk               ) ,
  .reset            ( reset             ) ,
  .core_index       ( core_index        ) ,
  .core_offset      ( core_offset       ) ,
  .core_wen         ( core_wen          ) ,
  .core_wstrb       ( core_wstrb        ) ,
  .core_wdata       ( core_wdata        ) ,
  .info_rsp         ( info_rsp          ) ,
  .info_hit         ( info_hit          ) ,
  .info_hit_way     ( info_hit_way      ) ,
  .info_hit_data    ( info_hit_data     ) ,
  .rplc_rsp         ( rplc_rsp          ) ,
  .rplc_rsp_data    ( rplc_rsp_data     ) ,
  .info_rplc_way    ( info_rplc_way     ) ,
  .core_rsp         ( core_rsp          ) ,
  .core_rdata       ( core_rdata        ) ,
  .rsp_arb          ( rsp_arb           ) ,
  .rsp_dirty_wen0   ( rsp_dirty_wen0    ) ,
  .rsp_dirty_waddr0 ( rsp_dirty_waddr0  ) ,
  .rsp_dirty_wdata0 ( rsp_dirty_wdata0  ) ,
  .rsp_dirty_wen1   ( rsp_dirty_wen1    ) ,
  .rsp_dirty_waddr1 ( rsp_dirty_waddr1  ) ,
  .rsp_dirty_wdata1 ( rsp_dirty_wdata1  ) ,
  .rsp_lru_wen      ( rsp_lru_wen       ) ,
  .rsp_lru_waddr    ( rsp_lru_waddr     ) ,
  .rsp_lru_wdata    ( rsp_lru_wdata     ) ,
  .rsp_data_cen0    ( rsp_data_cen0     ) ,
  .rsp_data_wen0    ( rsp_data_wen0     ) ,
  .rsp_data_addr0   ( rsp_data_addr0    ) ,
  .rsp_data_wdata0  ( rsp_data_wdata0   ) ,
  .rsp_data_wstrb0  ( rsp_data_wstrb0   ) , 
  .rsp_data_cen1    ( rsp_data_cen1     ) ,
  .rsp_data_wen1    ( rsp_data_wen1     ) ,
  .rsp_data_addr1   ( rsp_data_addr1    ) ,
  .rsp_data_wdata1  ( rsp_data_wdata1   ) ,
  .rsp_data_wstrb1  ( rsp_data_wstrb1   )
);

wire  sram_data_cen0   ; 
wire  sram_data_wen0   ; 
wire  [`SRAM_ADDR_W-1:0]   sram_data_addr0  ; 
wire  [`SRAM_DATA_W-1:0]   sram_data_wdata0 ; 
wire  [`SRAM_WSTRB_W-1:0]  sram_data_wstrb0 ;
wire  [`SRAM_DATA_W-1:0]   sram_data_rdata0 ; 

wire  sram_data_cen1   ; 
wire  sram_data_wen1   ; 
wire  [`SRAM_ADDR_W-1:0]   sram_data_addr1  ; 
wire  [`SRAM_DATA_W-1:0]   sram_data_wdata1 ; 
wire  [`SRAM_WSTRB_W-1:0]  sram_data_wstrb1 ;
wire  [`SRAM_DATA_W-1:0]   sram_data_rdata1 ; 

wire  sram_tag_cen0   ; 
wire  sram_tag_wen0   ; 
wire  [`SRAM_ADDR_W-1:0]   sram_tag_addr0  ; 
wire  [`CACHE_TAG_W-1:0]   sram_tag_wdata0 ; 
wire  [`CACHE_TAG_W-1:0]   sram_tag_rdata0 ; 
         
wire  sram_tag_cen1   ; 
wire  sram_tag_wen1   ; 
wire  [`SRAM_ADDR_W-1:0]   sram_tag_addr1  ; 
wire  [`CACHE_TAG_W-1:0]   sram_tag_wdata1 ; 
wire  [`CACHE_TAG_W-1:0]   sram_tag_rdata1 ; 

wire [`SRAM_ADDR_W-1:0] reg_value_raddr0 ; 
wire reg_value_rdata0 ; 
wire reg_value_wen0   ; 
wire [`SRAM_ADDR_W-1:0] reg_value_waddr0 ; 
wire reg_value_wdata0 ; 

wire [`SRAM_ADDR_W-1:0] reg_value_raddr1 ; 
wire reg_value_rdata1 ; 
wire reg_value_wen1   ; 
wire [`SRAM_ADDR_W-1:0] reg_value_waddr1 ; 
wire reg_value_wdata1 ; 

wire [`SRAM_ADDR_W-1:0] reg_dirty_raddr0 ; 
wire reg_dirty_rdata0 ; 
wire reg_dirty_wen0   ; 
wire [`SRAM_ADDR_W-1:0] reg_dirty_waddr0 ; 
wire reg_dirty_wdata0 ; 

wire [`SRAM_ADDR_W-1:0] reg_dirty_raddr1 ; 
wire reg_dirty_rdata1 ; 
wire reg_dirty_wen1   ; 
wire [`SRAM_ADDR_W-1:0] reg_dirty_waddr1 ; 
wire reg_dirty_wdata1 ; 

wire [`SRAM_ADDR_W-1:0] reg_lru_raddr ; 
wire reg_lru_rdata ; 
wire reg_lru_wen   ; 
wire [`SRAM_ADDR_W-1:0] reg_lru_waddr ; 
wire reg_lru_wdata ; 



cache_arbitrate  cache_arbitrate_inst(
  . info_arb          (  info_arb           )  ,
  . rplc_arb          (  rplc_arb           )  ,
  .  rsp_arb          (   rsp_arb           )  ,
  . info_data_cen0    (  info_data_cen0     )  ,
  . rplc_data_cen0    (  rplc_data_cen0     )  ,
  .  rsp_data_cen0    (   rsp_data_cen0     )  ,
  . sram_data_cen0    (  sram_data_cen0     )  ,
  . info_data_wen0    (  info_data_wen0     )  ,
  . rplc_data_wen0    (  rplc_data_wen0     )  ,
  .  rsp_data_wen0    (   rsp_data_wen0     )  ,
  . sram_data_wen0    (  sram_data_wen0     )  ,
  . info_data_addr0   (  info_data_addr0    )  ,
  . rplc_data_addr0   (  rplc_data_addr0    )  ,
  .  rsp_data_addr0   (   rsp_data_addr0    )  ,
  . sram_data_addr0   (  sram_data_addr0    )  ,
  . rplc_data_wstrb0  (  rplc_data_wstrb0   )  ,
  .  rsp_data_wstrb0  (   rsp_data_wstrb0   )  ,
  . sram_data_wstrb0  (  sram_data_wstrb0   )  ,
  . rplc_data_wdata0  (  rplc_data_wdata0   )  ,
  .  rsp_data_wdata0  (   rsp_data_wdata0   )  ,
  . sram_data_wdata0  (  sram_data_wdata0   )  ,
  . sram_data_rdata0  (  sram_data_rdata0   )  ,
  . info_data_rdata0  (  info_data_rdata0   )  ,
  . info_data_cen1    (  info_data_cen1     )  ,
  . rplc_data_cen1    (  rplc_data_cen1     )  ,
  .  rsp_data_cen1    (   rsp_data_cen1     )  ,
  . sram_data_cen1    (  sram_data_cen1     )  ,
  . info_data_wen1    (  info_data_wen1     )  ,
  . rplc_data_wen1    (  rplc_data_wen1     )  ,
  .  rsp_data_wen1    (   rsp_data_wen1     )  ,
  . sram_data_wen1    (  sram_data_wen1     )  ,
  . info_data_addr1   (  info_data_addr1    )  ,
  . rplc_data_addr1   (  rplc_data_addr1    )  ,
  .  rsp_data_addr1   (   rsp_data_addr1    )  ,
  . sram_data_addr1   (  sram_data_addr1    )  ,
  . rplc_data_wstrb1  (  rplc_data_wstrb1   )  ,
  .  rsp_data_wstrb1  (   rsp_data_wstrb1   )  ,
  . sram_data_wstrb1  (  sram_data_wstrb1   )  ,
  . rplc_data_wdata1  (  rplc_data_wdata1   )  ,
  .  rsp_data_wdata1  (   rsp_data_wdata1   )  ,
  . sram_data_wdata1  (  sram_data_wdata1   )  ,
  .sram_data_rdata1   ( sram_data_rdata1    ) ,
  .info_data_rdata1   ( info_data_rdata1    ) ,
  .info_tag_cen0      ( info_tag_cen0       ) ,
  .rplc_tag_cen0      ( rplc_tag_cen0       ) ,
  . sram_tag_cen0     (  sram_tag_cen0      ) ,
  .info_tag_wen0      ( info_tag_wen0       ) ,
  .rplc_tag_wen0      ( rplc_tag_wen0       ) ,
  .sram_tag_wen0      ( sram_tag_wen0       ) ,
  .info_tag_addr0     ( info_tag_addr0      ) ,
  .rplc_tag_addr0     ( rplc_tag_addr0      ) ,
  .sram_tag_addr0     ( sram_tag_addr0      ) ,
  .rplc_tag_wdata0    ( rplc_tag_wdata0     ) ,
  .sram_tag_wdata0    ( sram_tag_wdata0     ) ,
  .info_tag_rdata0    ( info_tag_rdata0     ) ,
  .sram_tag_rdata0    ( sram_tag_rdata0     ) ,
  .info_tag_cen1      ( info_tag_cen1       ) ,
  .rplc_tag_cen1      ( rplc_tag_cen1       ) ,
  .sram_tag_cen1      ( sram_tag_cen1       ) ,
  .info_tag_wen1      ( info_tag_wen1       ) ,
  .rplc_tag_wen1      ( rplc_tag_wen1       ) ,
  .sram_tag_wen1      ( sram_tag_wen1       ) ,
  .info_tag_addr1     ( info_tag_addr1      ) ,
  .rplc_tag_addr1     ( rplc_tag_addr1      ) ,
  .sram_tag_addr1     ( sram_tag_addr1      ) ,
  .rplc_tag_wdata1    ( rplc_tag_wdata1     ) ,
  .sram_tag_wdata1    ( sram_tag_wdata1     ) ,
  .info_tag_rdata1    ( info_tag_rdata1     ) ,
  .sram_tag_rdata1    ( sram_tag_rdata1     ) ,
  .info_dirty_raddr0  ( info_dirty_raddr0   ) ,
  . reg_dirty_raddr0  (  reg_dirty_raddr0   ) ,
  . reg_dirty_rdata0  (  reg_dirty_rdata0   ) ,
  .info_dirty_rdata0  ( info_dirty_rdata0   ) ,
  .info_dirty_raddr1  ( info_dirty_raddr1   ) ,
  . reg_dirty_raddr1  (  reg_dirty_raddr1   ) ,
  . reg_dirty_rdata1  (  reg_dirty_rdata1   ) ,
  .info_dirty_rdata1  ( info_dirty_rdata1   ) ,
  .info_value_raddr0  ( info_value_raddr0   ) ,
  . reg_value_raddr0  (  reg_value_raddr0   ) ,
  . reg_value_rdata0  (  reg_value_rdata0   ) ,
  .info_value_rdata0  ( info_value_rdata0   ) ,
  .info_value_raddr1  ( info_value_raddr1   ) ,
  .  reg_value_raddr1 (   reg_value_raddr1  )  ,
  .  reg_value_rdata1 (   reg_value_rdata1  )  ,
  . info_value_rdata1 (  info_value_rdata1  )  ,
  . info_lru_raddr    (  info_lru_raddr     )  ,
  .  reg_lru_raddr    (   reg_lru_raddr     )  ,
  .  reg_lru_rdata    (   reg_lru_rdata     )  ,
  . info_lru_rdata    (  info_lru_rdata     )  ,
  . rplc_dirty_wen0   (  rplc_dirty_wen0    )  ,
  .  rsp_dirty_wen0   (   rsp_dirty_wen0    )  ,
  .  reg_dirty_wen0   (   reg_dirty_wen0    )  ,
  . rplc_dirty_waddr0 (  rplc_dirty_waddr0  )  ,
  .  rsp_dirty_waddr0 (   rsp_dirty_waddr0  )  ,
  .  reg_dirty_waddr0 (   reg_dirty_waddr0  )  ,
  . rplc_dirty_wdata0 (  rplc_dirty_wdata0  )  ,
  .  rsp_dirty_wdata0 (   rsp_dirty_wdata0  )  ,
  .  reg_dirty_wdata0 (   reg_dirty_wdata0  )  ,
  . rplc_dirty_wen1   (  rplc_dirty_wen1    )  ,
  .  rsp_dirty_wen1   (   rsp_dirty_wen1    )  ,
  .  reg_dirty_wen1   (   reg_dirty_wen1    )  ,
  . rplc_dirty_waddr1 (  rplc_dirty_waddr1  )  ,
  .  rsp_dirty_waddr1 (   rsp_dirty_waddr1  )  ,
  .  reg_dirty_waddr1 (   reg_dirty_waddr1  )  ,
  . rplc_dirty_wdata1 (  rplc_dirty_wdata1  )  ,
  .  rsp_dirty_wdata1 (   rsp_dirty_wdata1  )  ,
  .  reg_dirty_wdata1 (   reg_dirty_wdata1  )  ,
  . rplc_value_wen0   (  rplc_value_wen0    )  ,
  .  reg_value_wen0   (   reg_value_wen0    )  , 
  . rplc_value_wen1   (  rplc_value_wen1    )  ,
  . reg_value_wen1    (  reg_value_wen1     )  ,
  . rplc_value_waddr0 (  rplc_value_waddr0  )  ,
  . reg_value_waddr0  (  reg_value_waddr0   )  ,
  . rplc_value_waddr1 (  rplc_value_waddr1  )  ,
  . reg_value_waddr1  (  reg_value_waddr1   )  ,
  . rplc_value_wdata0 (  rplc_value_wdata0  )  ,
  . reg_value_wdata0  (  reg_value_wdata0   )  ,
  . rplc_value_wdata1 (  rplc_value_wdata1  )  ,
  . reg_value_wdata1  (  reg_value_wdata1   )  ,
  . rsp_lru_wen       (  rsp_lru_wen        )  ,
  . reg_lru_wen       (  reg_lru_wen        )  ,
  . rsp_lru_waddr     (  rsp_lru_waddr      )  ,
  . reg_lru_waddr     (  reg_lru_waddr      )  ,
  . rsp_lru_wdata     (  rsp_lru_wdata      )  ,
  . reg_lru_wdata     (  reg_lru_wdata      )   
);


sram sram_tag0(
    .clk    ( clk             )  , 
    .cen    ( sram_tag_cen0   )  , 
    .wen    ( sram_tag_wen0   )  , 
    .addr   ( sram_tag_addr0  )  ,
    .wdata  ( sram_tag_wdata0 )  ,   
    .rdata  ( sram_tag_rdata0 )   
);

sram sram_tag1(
    .clk    ( clk             )  , 
    .cen    ( sram_tag_cen1   )  , 
    .wen    ( sram_tag_wen1   )  , 
    .addr   ( sram_tag_addr1  )  ,
    .wdata  ( sram_tag_wdata1 )  ,   
    .rdata  ( sram_tag_rdata1 )   
);

sram_wstrb sram_data0 (
    .clk    ( clk   )  , 
    .cen    ( sram_data_cen0  )  , 
    .wen    ( sram_data_wen0  )  , 
    .addr   ( sram_data_addr0 )  ,
    .wdata  ( sram_data_wdata0)  ,   
    .wstrb  ( sram_data_wstrb0)  , 
    .rdata  ( sram_data_rdata0)   
);

sram_wstrb sram_data1 (
    .clk    ( clk   )  , 
    .cen    ( sram_data_cen1  )  , 
    .wen    ( sram_data_wen1  )  , 
    .addr   ( sram_data_addr1 )  ,
    .wdata  ( sram_data_wdata1)  ,   
    .wstrb  ( sram_data_wstrb1)  , 
    .rdata  ( sram_data_rdata1)   
);

regfile reg_dirty0 (
  .clk   ( clk    )  ,
  .reset ( reset  )  ,
  .raddr ( reg_dirty_raddr0 )  ,
  .rdata ( reg_dirty_rdata0 )  ,
  .wen   ( reg_dirty_wen0   )  ,
  .waddr ( reg_dirty_waddr0 )  ,
  .wdata ( reg_dirty_wdata0 )  
);

regfile reg_dirty1 (
  .clk   ( clk    )  ,
  .reset ( reset  )  ,
  .raddr ( reg_dirty_raddr1 )  ,
  .rdata ( reg_dirty_rdata1 )  ,
  .wen   ( reg_dirty_wen1   )  ,
  .waddr ( reg_dirty_waddr1 )  ,
  .wdata ( reg_dirty_wdata1 )  
);

regfile reg_value0 (
  .clk   ( clk    )  ,
  .reset ( reset  )  ,
  .raddr ( reg_value_raddr0 )  ,
  .rdata ( reg_value_rdata0 )  ,
  .wen   ( reg_value_wen0   )  ,
  .waddr ( reg_value_waddr0 )  ,
  .wdata ( reg_value_wdata0 )  
);

regfile reg_value1 (
  .clk   ( clk    )  ,
  .reset ( reset  )  ,
  .raddr ( reg_value_raddr1 )  ,
  .rdata ( reg_value_rdata1 )  ,
  .wen   ( reg_value_wen1   )  ,
  .waddr ( reg_value_waddr1 )  ,
  .wdata ( reg_value_wdata1 )  
);

regfile reg_lru (
  .clk   ( clk            )  ,
  .reset ( reset          )  ,
  .raddr ( reg_lru_raddr  )  ,
  .rdata ( reg_lru_rdata  )  ,
  .wen   ( reg_lru_wen    )  ,
  .waddr ( reg_lru_waddr  )  ,
  .wdata ( reg_lru_wdata  )  
);


endmodule

