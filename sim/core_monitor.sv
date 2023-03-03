
`ifndef CORE_MONITOR__SV
`define CORE_MONITOR__SV

class core_monitor;
  local string name;
  virtual core_if intf;
  mailbox #(core_trans)  mnt_mb;

  function new(string name = "core_monitor");
    this.name = name;
  endfunction

  function void set_interface(virtual core_if intf);
    if(intf == null)
      $fatal("[INTF FATAL]: interface is null!");
    else
      this.intf = intf;
  endfunction

  task run();
    forever begin
      core_trans trans;
      trans = new();
      @(posedge intf.clk iff( intf.mnt_ck.cen && intf.mnt_ck.rsp ));
      trans.wen   = intf.mnt_ck.wen   ;
      trans.wdata = intf.mnt_ck.wdata ;
      trans.wstrb = intf.mnt_ck.wstrb ;
      trans.rdata = intf.mnt_ck.rdata ;
      trans.addr  = intf.mnt_ck.addr  ;
      //$display(trans.sprint);
      this.mnt_mb.put(trans);
    end
  endtask

endclass:core_monitor

`endif
