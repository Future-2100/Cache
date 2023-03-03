
`ifndef BASE_TEST__SV
`define BASE_TEST__SV

class base_test;
  protected string name;
  local int timeout = 10 ;// for watching dog, 10ms

  core_generator core_gen;
  cache_env env;

  function new(string name = "base_test");
    this.name = name ;
    this.core_gen = new({name, ".core_generator"});
    this.env = new({name, ".cache_env"});
  endfunction

  function void do_config();
    this.env.drv_req_mb  = this.core_gen.drv_req_mb ;
    this.env.drv_rsp_mb  = this.core_gen.drv_rsp_mb ;
    this.env.do_config();
    rpt_pkg::logname = {this.name, "_check.log"};
    rpt_pkg::clean_log();
    $display("%s instantiated and connected objects", this.name);
  endfunction

  function void set_interface(virtual core_if intf, virtual axi_arif arif, virtual axi_rif rif, virtual axi_awif awif, virtual axi_wif wif, virtual axi_bif bif);
    this.env.set_interface(intf, arif, rif, awif, wif, bif);
  endfunction

  virtual task run();
    fork
      this.env.run();
    join_none
    rpt_pkg::rpt_msg("[TEST]",
      $sformatf("=====================%s AT TIME %0t STARTED=====================", this.name, $time),
      rpt_pkg::INFO,
      rpt_pkg::HIGH
    );
    fork
      this.do_data();
      this.do_watchdog();
    join_any
    rpt_pkg::rpt_msg("TEST",
      $sformatf("=====================%s AT TIME %0t FINISHED=====================", this.name, $time),
      rpt_pkg::INFO,
      rpt_pkg::HIGH
    );
    this.do_report();
    $finish();
  endtask

  virtual task do_watchdog();
    rpt_pkg::rpt_msg("[TEST]",
      $sformatf("=====================%s AT TIME %0t WATCHDOG GUARDING=====================", this.name, $time),
      rpt_pkg::INFO,
      rpt_pkg::HIGH
    );
    #(this.timeout * 1ms);
    rpt_pkg::rpt_msg("[TEST]",
      $sformatf("=====================%s AT TIME %0t WATCHDOG BARKING=====================", this.name, $time),
      rpt_pkg::INFO,
      rpt_pkg::HIGH
    );
  endtask

  virtual function void do_report();
    this.env.do_report();
    rpt_pkg::do_report();
  endfunction

  virtual task do_data();
  endtask

endclass:base_test


class read_test extends base_test;
  
  function new(string name = "read_test");
    super.new(name);
  endfunction
  
  virtual function void config_core_gen();
	core_gen.mode = new[4];
	core_gen.mode[0].option = core_gen.READ;
	core_gen.mode[0].begin_addr = 64'h8000_0000;
	core_gen.mode[0].repeat_time= 32*8*2;
	
    core_gen.mode[1].option = core_gen.READ;
	core_gen.mode[1].begin_addr = 64'h8000_0000;
	core_gen.mode[1].repeat_time= 32*8*2;
	
	core_gen.mode[2].option = core_gen.READ;
	core_gen.mode[2].begin_addr = 64'h8100_0000;
	core_gen.mode[2].repeat_time= 32*8*2;
	
    core_gen.mode[3].option = core_gen.READ;
	core_gen.mode[3].begin_addr = 64'h8100_0000;
	core_gen.mode[3].repeat_time= 32*8*2;
  endfunction

  virtual task do_data();
    this.config_core_gen();
    fork
      core_gen.run();
    join
    #100ns;
  endtask

endclass:read_test

class write_test extends base_test;
  
  function new(string name = "write_test");
    super.new(name);
  endfunction
  
  virtual function void config_core_gen();
	core_gen.mode = new[9];
	
	//test 1
	core_gen.mode[0].option = core_gen.READ;
	core_gen.mode[0].begin_addr = 64'h8000_0000;
	core_gen.mode[0].repeat_time= 32*8*2;
	
    core_gen.mode[1].option = core_gen.WRITE;
	core_gen.mode[1].begin_addr = 64'h8000_0000;
	core_gen.mode[1].repeat_time= 32*8*2;
	
	core_gen.mode[2].option = core_gen.READ;
	core_gen.mode[2].begin_addr = 64'h8000_0000;
	core_gen.mode[2].repeat_time= 32*8*2;
	
    core_gen.mode[3].option = core_gen.READ;
	core_gen.mode[3].begin_addr = 64'h8100_0000;
	core_gen.mode[3].repeat_time= 32*8*2;
	
	core_gen.mode[4].option = core_gen.READ;
	core_gen.mode[4].begin_addr = 64'h8000_0000;
	core_gen.mode[4].repeat_time= 32*8*2;
	
	// test 2
	
	core_gen.mode[5].option = core_gen.WRITE;
	core_gen.mode[5].begin_addr = 64'h8200_0000;
	core_gen.mode[5].repeat_time= 32*8*2;
	
	core_gen.mode[6].option = core_gen.READ;
	core_gen.mode[6].begin_addr = 64'h8200_0000;
	core_gen.mode[6].repeat_time= 32*8*2;
	
	core_gen.mode[7].option = core_gen.READ;
	core_gen.mode[7].begin_addr = 64'h8300_0000;
	core_gen.mode[7].repeat_time= 32*8*2;
	
	core_gen.mode[8].option = core_gen.READ;
	core_gen.mode[8].begin_addr = 64'h8200_0000;
	core_gen.mode[8].repeat_time= 32*8*2;
	
  endfunction

  virtual task do_data();
    this.config_core_gen();
    fork
      core_gen.run();
    join
    #100ns;
  endtask

endclass:write_test

class replace_algorithm_test extends base_test;

  function new(string name = "replace_algorithm_test");
    super.new(name);
  endfunction
  
  virtual function void config_core_gen();
	core_gen.mode = new[4];
	
	core_gen.mode[0].option = core_gen.READ;
	core_gen.mode[0].begin_addr = 64'h8000_0000;
	core_gen.mode[0].repeat_time= 32*8*2;
	
    core_gen.mode[1].option = core_gen.READ;
	core_gen.mode[1].begin_addr = 64'h8000_0000;
	core_gen.mode[1].repeat_time= 32*8*1;
	
	core_gen.mode[2].option = core_gen.READ;
	core_gen.mode[2].begin_addr = 64'h8100_0000;
	core_gen.mode[2].repeat_time= 32*8*1;
	
    core_gen.mode[3].option = core_gen.READ;
	core_gen.mode[3].begin_addr = 64'h8000_0000;
	core_gen.mode[3].repeat_time= 32*8*1;
  endfunction

  virtual task do_data();
    this.config_core_gen();
    fork
      core_gen.run();
    join
    #100ns;
  endtask

endclass:replace_algorithm_test


`endif
