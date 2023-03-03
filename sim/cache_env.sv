
`ifndef CACHE_ENV__SV
`define CACHE_ENV__SV

class cache_env;
  protected string name;

  core_agent     core_agt;
  axi_driver     axi_drv ;
  axi_generator  axi_gen ;
  cache_checker  chker   ;
  cache_coverage cvrg    ;

  mailbox #(core_trans) drv_req_mb;
  mailbox #(core_trans) drv_rsp_mb;

  function new(string name = "base_test");
    this.name = name ;
    this.core_agt = new({name, ".core_agent"});
    this.axi_drv  = new({name, ".axi_driver"});
    this.axi_gen  = new({name, ".axi_generator"}) ;
    this.chker    = new({name, ".checker"});
	this.cvrg = new();
  endfunction

  function void do_config();
    this.chker.do_config(axi_gen.bank);
    this.core_agt.drv_req_mb  = this.drv_req_mb ;
    this.core_agt.drv_rsp_mb  = this.drv_rsp_mb ;
    this.core_agt.mnt_mb  = this.chker.mnt_mb     ;
    this.core_agt.do_config();
    this.axi_drv.arreq_mb = this.axi_gen.arreq_mb ; 
    this.axi_drv.arrsp_mb = this.axi_gen.arrsp_mb ; 
    this.axi_drv.rreq_mb  = this.axi_gen.rreq_mb  ; 
    this.axi_drv.rrsp_mb  = this.axi_gen.rrsp_mb  ; 
    this.axi_drv.awreq_mb = this.axi_gen.awreq_mb ; 
    this.axi_drv.awrsp_mb = this.axi_gen.awrsp_mb ; 
    this.axi_drv.wreq_mb  = this.axi_gen.wreq_mb  ; 
    this.axi_drv.wrsp_mb  = this.axi_gen.wrsp_mb  ; 
    this.axi_drv.breq_mb  = this.axi_gen.breq_mb  ; 
    this.axi_drv.brsp_mb  = this.axi_gen.brsp_mb  ; 
  endfunction

  function void set_interface(virtual core_if intf, virtual axi_arif arif, virtual axi_rif rif, virtual axi_awif awif, virtual axi_wif wif, virtual axi_bif bif);
    this.core_agt.set_interface(intf);
	this.cvrg.set_interface(intf);
    this.axi_drv.set_interface(arif, rif, awif, wif, bif);
  endfunction

  task run();
    fork
      this.core_agt.run();
      this.axi_drv.run();
      this.axi_gen.run();
      this.chker.run();
	  this.cvrg.run();
    join
  endtask

  virtual function void do_report();
    this.chker.do_report();
    this.cvrg.do_report();
  endfunction

endclass:cache_env

`endif
