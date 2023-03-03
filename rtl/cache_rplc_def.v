`ifndef CACHE_RPLC_DEF__V
`define CACHE_RPLC_DEF__V

`include "global_config.v"
`include "cache_define.v"
`include "axi_define.v"

`define RPLC_ARID     `CACHE_TYPE
`define RPLC_ARLEN    'd7
`define RPLC_ARSIZE   `AxSIZE_8bytes
`define RPLC_ARBURST  `AxBURST_INCR
`define RPLC_ARLOCK   `AxLOCK_normal
`define RPLC_ARCACHE  `AxCACHE_default
`define RPLC_ARPORT   `AxPORT_default
`define RPLC_ARQOS    `AxQOS_default
`define RPLC_ARREGION `AxREGION_default

`define RPLC_RID      `CACHE_TYPE
`define RPLC_RRESP    `AxRESP_OKAY

`endif

