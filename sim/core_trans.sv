
`ifndef CORE_TRANS__SV
`define CORE_TRANS__SV

class core_trans;

  rand bit        cen   ;
  rand bit [63:0] addr  ;
  rand bit        wen   ;
  rand bit [63:0] wdata ;
  rand bit [7:0]  wstrb ;
       bit [63:0] rdata ;

       bit rsp = 0 ;

  constraint cstr{
	cen==1'b1 -> addr inside {[64'h8000_0000:64'h8fff_ffff]};
	(wen==1'b1 && cen==1'b1) -> wstrb inside {8'b1, 8'b11, 8'h0f, 8'hff};
  }

  function core_trans clone();
    core_trans c = new();
	c.cen  = this.cen  ;
    c.addr = this.addr ;
    c.wen  = this.wen  ;
    c.wdata= this.wdata;
    c.wstrb= this.wstrb;
    c.rdata= this.rdata;
    c.rsp  = this.rsp  ;
    return c ;
  endfunction

  function string sprint();
    string s;
    s = {s, $sformatf("=======================================\n")};
    s = {s, $sformatf("core_trans object content is as below: \n")};
	s = {s, $sformatf("cen   = %0h \n", this.cen  )};
    s = {s, $sformatf("addr  = %0h \n", this.addr )};
    s = {s, $sformatf("wen   = %0h \n", this.wen  )};
    s = {s, $sformatf("wdata = %0h \n", this.wdata)};
    s = {s, $sformatf("wstrb = %0h \n", this.wstrb)};
    s = {s, $sformatf("rdata = %0h \n", this.rdata)};
    s = {s, $sformatf("=======================================\n")};
    return s ;
  endfunction

endclass:core_trans

`endif

