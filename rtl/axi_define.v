`ifndef AXI_DEFINE__V
`define AXI_DEFINE__V

`define AxID_W      4 
`define AxADDR_W    64
`define AxDATA_W    64
`define AxLEN_W     8 
`define AxSIZE_W    3     
`define AxBURST_W   2   
`define AxCACHE_W   4    
`define AxPORT_W    3    
`define AxQOS_W     4       
`define AxREGION_W  4      
`define AxUSER_W    1     
`define AxRESP_W    2

`define AxWSTRB_W   `AxDATA_W/8

// config
`define AxSIZE_1bytes   'b000
`define AxSIZE_2bytes   'b001
`define AxSIZE_4bytes   'b010
`define AxSIZE_8bytes   'b011
`define AxSIZE_16bytes  'b100
`define AxSIZE_32bytes  'b101
`define AxSIZE_64bytes  'b110
`define AxSIZE_128bytes 'b111

`define AxBURST_FIXED   'b00
`define AxBURST_INCR    'b01
`define AxBURST_WRAP    'b10

`define AxLOCK_normal    'b0
`define AxLOCK_exclusive 'b1

`define AxCACHE_default  'b0

`define AxPORT_default   'b0

`define AxQOS_default    'b0

`define AxREGION_default 'b0

`define AxRESP_OKAY      'b00
`define AxRESP_EXOKAY    'b01
`define AxRESP_SLVERR    'b10
`define AxRESP_DECERR    'b11

`endif
