`ifndef AXI_ARTRANS__SV
`define AXI_ARTRANS__SV

`include "../rtl/axi_define.v"
//--------------------------------------------


class axi_artrans;

  bit  [3:0]     arid  = 0 ;
  bit  [63:0]  araddr  = 0 ;
  bit  [7:0]    arlen  = 0 ;
  bit  [2:0]   arsize  = 0 ;
  bit  [1:0]  arburst  = 0 ;
  bit  [3:0]  arcache  = 0 ;
  bit  [2:0]   arport  = 0 ;
  bit  [3:0]    arqos  = 0 ;
  bit  [3:0] arregion  = 0 ;
  bit          arlock  = 0 ;

  bit rsp;

  rand int nidles;

  constraint arready_cnstrnt{
    nidles inside {[1:100]};
  };

  function string sprint();
    string s;
    s = {s, $sformatf("=======================================\n")};
    s = {s, $sformatf("axi_artrans object content is as below: \n")};
	s = {s, $sformatf("arid    = %0h \n", this.arid    )};
    s = {s, $sformatf("araddr  = %0h \n", this.araddr  )};
    s = {s, $sformatf("arlen   = %0h \n", this.arlen   )};
    s = {s, $sformatf("arsize  = %0h \n", this.arsize  )};
    s = {s, $sformatf("arburst = %0h \n", this.arburst )};
    s = {s, $sformatf("arcache = %0h \n", this.arcache )};
	s = {s, $sformatf("arport  = %0h \n", this.arport  )};
	s = {s, $sformatf("arqos   = %0h \n", this.arqos   )};
	s = {s, $sformatf("arregion= %0h \n", this.arregion)};
	s = {s, $sformatf("arlock  = %0h \n", this.arlock  )};
    s = {s, $sformatf("=======================================\n")};
    return s ;
  endfunction


endclass:axi_artrans


//--------------------------------------------


class axi_rtrans;
  bit   [`AxID_W-1:0]     rid       ;
  bit   [`AxDATA_W-1:0]   rdata[]   ;
  bit   [`AxRESP_W-1:0]   rresp     ;
  bit                     rlast     ;
  bit rsp;

  rand int nidles;

  constraint rvalidy_cnstrnt{
    nidles inside {[1:100]};
  };
  
  function string sprint();
    string s;
    s = {s, $sformatf("=======================================\n")};
    s = {s, $sformatf("axi_rtrans object content is as below: \n")};
	s = {s, $sformatf("rid        = %0h \n", this.rid    )};
	foreach(rdata[i])
	s = {s, $sformatf("rdata[%d]  = %0h \n", i, this.rdata[i]  )};
	s = {s, $sformatf("rresp      = %0h \n", this.rresp  )};
    s = {s, $sformatf("=======================================\n")};
    return s ;
  endfunction

endclass:axi_rtrans


//--------------------------------------------


class axi_awtrans;
  bit   [`AxID_W-1:0]     awid      ;
  bit   [`AxADDR_W-1:0]   awaddr    ;
  bit   [`AxLEN_W-1:0]    awlen     ;
  bit   [`AxSIZE_W-1:0]   awsize    ;
  bit   [`AxBURST_W-1:0]  awburst   ;
  bit   [`AxCACHE_W-1:0]  awcache   ;
  bit   [`AxPORT_W-1:0]   awport    ;
  bit   [`AxQOS_W-1:0]    awqos     ;
  bit   [`AxREGION_W-1:0] awregion  ;
  bit                     awlock    ;
  bit rsp;

  rand int nidles;

  constraint awready_cnstrnt{
    nidles inside {[1:100]};
  };
  
  function string sprint();
    string s;
    s = {s, $sformatf("=======================================\n")};
    s = {s, $sformatf("axi_awtrans object content is as below: \n")};
	s = {s, $sformatf("awid    = %0h \n", this.awid    )};
    s = {s, $sformatf("awaddr  = %0h \n", this.awaddr  )};
    s = {s, $sformatf("awlen   = %0h \n", this.awlen   )};
    s = {s, $sformatf("awsize  = %0h \n", this.awsize  )};
    s = {s, $sformatf("awburst = %0h \n", this.awburst )};
    s = {s, $sformatf("awcache = %0h \n", this.awcache )};
	s = {s, $sformatf("awport  = %0h \n", this.awport  )};
	s = {s, $sformatf("awqos   = %0h \n", this.awqos   )};
	s = {s, $sformatf("awregion= %0h \n", this.awregion)};
	s = {s, $sformatf("awlock  = %0h \n", this.awlock  )};
    s = {s, $sformatf("=======================================\n")};
    return s ;
  endfunction
  
endclass:axi_awtrans


//--------------------------------------------


class axi_wtrans;
  bit   [`AxID_W-1:0]     wid       ;
  bit   [`AxDATA_W-1:0]   wdata     ;
  bit   [`AxWSTRB_W-1:0]  wstrb     ;
  bit                     wlast     ;
  bit rsp;

  rand int nidles;

  constraint wready_cnstrnt{
    nidles inside {[1:100]};
  };
  
  function string sprint();
    string s;
    s = {s, $sformatf("=======================================\n")};
    s = {s, $sformatf("axi_wtrans object content is as below: \n")};
	s = {s, $sformatf("wid    = %0h \n", this.wid    )};
	s = {s, $sformatf("wdata  = %0h \n", this.wdata  )};
	s = {s, $sformatf("wstrb  = %0h \n", this.wstrb  )};
	s = {s, $sformatf("wlast  = %0h \n", this.wlast  )};
	s = {s, $sformatf("nidles = %0h \n", this.nidles )};
    s = {s, $sformatf("=======================================\n")};
    return s ;
  endfunction
  
  
endclass:axi_wtrans


//--------------------------------------------


class axi_btrans;
  bit   [`AxID_W-1:0]     bid       ;
  bit   [`AxRESP_W-1:0]   bresp     ;
  bit rsp;

  rand int nidles;

  constraint bready_cnstrnt{
    nidles inside {[1:100]};
  };
endclass:axi_btrans


//--------------------------------------------

`endif

