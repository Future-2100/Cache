`ifndef CACHE_DEFINE__V
`define CACHE_DEFINE__V

// choose I-cache or D-cache, if not choose, D-cache is default
`ifdef I_CACHE
  `define CACHE_TYPE 0 // I cache
`else
  `define CACHE_TYPE 1 // D cache
`endif

`define CORE_ADDR_W 64
`define CORE_DATA_W 64
`define CORE_WSTRB_W `CORE_DATA_W/8 

`define SRAM_SIZE 4*1024   // units: byte, only include data, exclude tags
`define CACHE_LINE_W  64*8 // units: 512 bits, 64 bytes
`define CACHE_GROUP 2      // two ways

`define SRAM_DEPTH `SRAM_SIZE/`CACHE_LINE_W/8/`CACHE_GROUP

`define CACHE_DATA_W `CACHE_LINE_W
`define CACHE_INDEX_W $clog2(`SRAM_DEPTH)

`define CACHE_TAG_W `CORE_ADDR_W-`CACHE_INDEX_W-`CACHE_OFFSET_W-$clog2(`CORE_DATA_W/8)

`define SRAM_ADDR_W   `CACHE_INDEX_W
`define SRAM_DATA_W   `CACHE_LINE_W
`define SRAM_TAG_W    `CACHE_TAG_W
`define SRAM_WSTRB_W  `CACHE_LINE_W/8

`define CACHE_DATA_N  `CACHE_LINE_W/`CORE_DATA_W

`define CACHE_OFFSET_W $clog2(`CACHE_DATA_N)

`define CACHE_OFFSET_LOCAL `CACHE_OFFSET_W+$clog2(`CORE_DATA_W/8)-1:$clog2(`CORE_DATA_W/8)
`define CACHE_INDEX_LOCAL `CACHE_INDEX_W+`CACHE_OFFSET_W+$clog2(`CORE_DATA_W/8)-1:`CACHE_OFFSET_W+$clog2(`CORE_DATA_W/8) 
`define CACHE_TAG_LOCAL `CACHE_TAG_W+`CACHE_INDEX_W+`CACHE_OFFSET_W+$clog2(`CORE_DATA_W/8)-1:`CACHE_INDEX_W+`CACHE_OFFSET_W+$clog2(`CORE_DATA_W/8)

`endif

