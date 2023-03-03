`ifndef CACHE_COVERAGE__SV
`define CACHE_COVERAGE__SV

class cache_coverage;
	local virtual core_if intf;
	local string name;
	
	covergroup read_group;
	  wstrb: coverpoint intf.wstrb {
	    bins  byte_w       = {8'b1   };
		bins  halfword_w   = {8'b11  };
		bins  word_w       = {8'b1111};
		bins  doubleword_w = {8'hff  };
	  }
	endgroup
	
    covergroup write_group;
	  wstrb: coverpoint intf.wstrb {
	    bins  byte_w       = {8'b1   };
		bins  halfword_w   = {8'b11  };
		bins  word_w       = {8'b1111};
		bins  doubleword_w = {8'hff  };
	  }
	endgroup
	
	function new(string name="cache_coverage"); 
	  this.name = name ;
	  this.read_group = new();
	  this.write_group = new();
	endfunction
	
	task run();
	  fork
		this.write_sample();
		this.read_sample();
		join
	endtask
	
	task read_sample();
	  forever begin
	    @(posedge intf.clk iff intf.reset);
		if(intf.cen==1'b1 && intf.wen==1'b0)
		  this.read_group.sample();
	  end
	endtask
	
    task write_sample();
	  forever begin
	    @(posedge intf.clk iff intf.reset);
		if(intf.cen==1'b1 && intf.wen==1'b1)
		  this.write_group.sample();
	  end
	endtask
	
	virtual function void set_interface(virtual core_if intf);
	  if(intf == null)
	    $error("[error]:core interface handle is NULL!!!");
      else
	    this.intf = intf;
	endfunction
	
    function void do_report();
      string s;
      s = "\n---------------------------------------------------------------\n";
      s = {s, "COVERAGE SUMMARY \n"}; 
      s = {s, $sformatf("total coverage: %.1f \n", $get_coverage())}; 
      s = {s, $sformatf("  read_group  coverage: %.1f \n", this.read_group.get_coverage())}; 
      s = {s, $sformatf("  write_group coverage: %.1f \n", this.write_group.get_coverage())}; 
      s = {s, "---------------------------------------------------------------\n"};
      rpt_pkg::rpt_msg($sformatf("[%s]",this.name), s, rpt_pkg::INFO, rpt_pkg::TOP);
    endfunction

endclass

`endif