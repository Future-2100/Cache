
`ifndef CORE_AGENT__SV
`define CORE_AGENT__SV

class core_agent;
  local string name;
  core_driver  driver;
  core_monitor monitor;
  virtual core_if intf;

  mailbox #(core_trans) drv_req_mb;
  mailbox #(core_trans) drv_rsp_mb;
  mailbox #(core_trans)     mnt_mb;

  function new(string name = "core_agent");
    this.name = name;
    this.driver  = new({name, ".driver"});
    this.monitor = new({name, ".monitor"});
  endfunction

  function void do_config();
    this.driver.req_mb = this.drv_req_mb;
    this.driver.rsp_mb = this.drv_rsp_mb;
    this.monitor.mnt_mb= this.mnt_mb;
  endfunction

  function void set_interface(virtual core_if intf);
    this.intf = intf;
    driver.set_interface(intf);
    monitor.set_interface(intf);
  endfunction

  task run();
    fork
      driver.run();
      monitor.run();
    join
  endtask

endclass

`endif

