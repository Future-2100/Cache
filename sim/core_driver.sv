
`ifndef CORE_DRIVER__SV
`define CORE_DRIVER__SV

class core_driver;
  local string name   ;
  virtual core_if intf;

  mailbox #(core_trans) req_mb;
  mailbox #(core_trans) rsp_mb;

  function new(string name = "core_driver");
    this.name = name;
  endfunction

  function void set_interface(virtual core_if intf);
    if(intf == null)
      $fatal("intf is null!");
    else
      this.intf = intf;
  endfunction

  task run();
    fork
      this.drive();
      this.reset();
    join
  endtask

  task drive();
    @(posedge intf.reset);
    forever begin
      core_trans req;
      this.req_mb.get(req);
      @(posedge intf.clk);
      intf.drv_ck.cen   <= req.cen   ;
      intf.drv_ck.wen   <= req.wen   ;
      intf.drv_ck.addr  <= req.addr  ;
      intf.drv_ck.wdata <= req.wdata ;
      intf.drv_ck.wstrb <= req.wstrb ;
	  if(req.cen == 1'b1) begin 
        @(negedge intf.clk);
        wait(intf.rsp == 1'b1);
        req.rsp = 1 ;
        this.rsp_mb.put(req);
	  end
    end
  endtask

  task reset();
    forever begin
      @(posedge intf.clk iff(!intf.reset));
      intf.drv_ck.cen   <=  1'b0 ;
      intf.drv_ck.wen   <=  1'b0 ;
      intf.drv_ck.addr  <= 64'b0 ;
      intf.drv_ck.wdata <= 64'b0 ;
      intf.drv_ck.wstrb <=  8'b0 ;
    end
  endtask

endclass:core_driver

`endif

