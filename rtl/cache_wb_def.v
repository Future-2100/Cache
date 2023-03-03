`ifndef CACHE_WB_DEF__V
`define CACHE_WB_DEF__V

`include "global_config.v"
`include "cache_define.v"
`include "axi_define.v"

`define WB_AWID     `CACHE_TYPE
`define WB_AWLEN    'd7    // 8
`define WB_AWSIZE   `AxSIZE_8bytes 
`define WB_AWBURST  `AxBURST_INCR  
`define WB_AWLOCK   `AxLOCK_normal
`define WB_AWCACHE  `AxCACHE_default
`define WB_AWPORT   `AxPORT_default
`define WB_AWQOS    `AxQOS_default
`define WB_AWREGION `AxREGION_default

`define WB_WID      `CACHE_TYPE

`define WB_BID      `CACHE_TYPE
`define WB_BRESP    `AxRESP_OKAY

`endif

