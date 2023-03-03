
`include "interface.sv"

module tb;


logic clk   ;
logic reset ;

core_if  core_intf (.*);
axi_arif axi_arintf(.*);
axi_rif  axi_rintf (.*);
axi_awif axi_awintf(.*);
axi_wif  axi_wintf (.*);
axi_bif  axi_bintf (.*);

cache_top dut (
    .clk           ( clk                 )  
  , .reset         ( reset               )  
  , .core_cen      ( core_intf.cen       )  
  , .core_wen      ( core_intf.wen       )  
  , .core_addr     ( core_intf.addr      )  
  , .core_wdata    ( core_intf.wdata     )  
  , .core_wstrb    ( core_intf.wstrb     )  
  , .core_rsp      ( core_intf.rsp       )  
  , .core_rdata    ( core_intf.rdata     )  
  , .axi_arid      ( axi_arintf.arid     )  
  , .axi_araddr    ( axi_arintf.araddr   )  
  , .axi_arlen     ( axi_arintf.arlen    )  
  , .axi_arsize    ( axi_arintf.arsize   )  
  , .axi_arburst   ( axi_arintf.arburst  )  
  , .axi_arlock    ( axi_arintf.arlock   )  
  , .axi_arcache   ( axi_arintf.arcache  )  
  , .axi_arport    ( axi_arintf.arport   )  
  , .axi_arqos     ( axi_arintf.arqos    )  
  , .axi_arregion  ( axi_arintf.arregion )  
  , .axi_arvalid   ( axi_arintf.arvalid  )  
  , .axi_arready   ( axi_arintf.arready  )  
  , .axi_rid       ( axi_rintf.rid       )  
  , .axi_rdata     ( axi_rintf.rdata     )  
  , .axi_rresp     ( axi_rintf.rresp     )  
  , .axi_rlast     ( axi_rintf.rlast     )  
  , .axi_rvalid    ( axi_rintf.rvalid    )  
  , .axi_rready    ( axi_rintf.rready    )  
  , .axi_awid      ( axi_awintf.awid     )  
  , .axi_awaddr    ( axi_awintf.awaddr   )  
  , .axi_awlen     ( axi_awintf.awlen    )  
  , .axi_awsize    ( axi_awintf.awsize   )  
  , .axi_awburst   ( axi_awintf.awburst  )  
  , .axi_awlock    ( axi_awintf.awlock   )  
  , .axi_awcache   ( axi_awintf.awcache  )  
  , .axi_awport    ( axi_awintf.awport   )  
  , .axi_awqos     ( axi_awintf.awqos    )  
  , .axi_awregion  ( axi_awintf.awregion )  
  , .axi_awvalid   ( axi_awintf.awvalid  )  
  , .axi_awready   ( axi_awintf.awready  )  
  , .axi_wid       ( axi_wintf.wid       )  
  , .axi_wdata     ( axi_wintf.wdata     )  
  , .axi_wstrb     ( axi_wintf.wstrb     )  
  , .axi_wlast     ( axi_wintf.wlast     )  
  , .axi_wvalid    ( axi_wintf.wvalid    )  
  , .axi_wready    ( axi_wintf.wready    )  
  , .axi_bid       ( axi_bintf.bid       )  
  , .axi_bresp     ( axi_bintf.bresp     )  
  , .axi_bvalid    ( axi_bintf.bvalid    )  
  , .axi_bready    ( axi_bintf.bready    )   
);


import cache_pkg::*;

// clock generation
initial begin
  clk <= 0;
  forever begin
    #5 clk <= !clk;
  end
end

// reset trigger
initial begin
  reset   <= 0;
  repeat(10) @(posedge clk);
    reset <= 1;
end


/*
initial begin
  //$fsdbDumpfile("tb.fsdb");
  //$fsdbDumpvars(0, tb);
  $vcdpluson(0, tb);
end
*/

read_test t1;
write_test t2;
replace_algorithm_test t3;
base_test tests[string];
string name;

initial begin
  t1 = new();
  t2 = new();
  t3 = new();
  tests["read_test"] = t1 ;
  tests["write_test"] = t2 ;
  tests["replace_algorithm_test"] = t3 ;
  if($value$plusargs("TESTNAME=%s", name)) begin
    if(tests.exists(name)) begin
    tests[name].set_interface(core_intf, axi_arintf, axi_rintf, axi_awintf, axi_wintf, axi_bintf );
    tests[name].do_config();
    tests[name].run();
    end
    else begin
      $fatal("ERRTEST, test name %s is invalid, please specify a valid name!", name);
    end
  end
  else begin
    $display("No runtime option +TESTNAME=xxx is configured, and run default test first_test");
    tests["read_test"].set_interface(core_intf, axi_arintf, axi_rintf, axi_awintf, axi_wintf, axi_bintf );
    tests["read_test"].do_config();
    tests["read_test"].run();
  end
end

endmodule

