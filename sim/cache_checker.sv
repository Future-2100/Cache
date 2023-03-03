
`ifndef CACHE_CHECKER__SV
`define CACHE_CHECKER__SV

class cache_checker;

  local string name ;
  local int    err_count;
  local int    total_count;

  mailbox #(core_trans)  mnt_mb;

  memory bank;

  function new(string name = "cache_checker");
    this.name = name;
    this.mnt_mb = new();
    this.err_count = 0;
    this.total_count = 0;
  endfunction

  function void do_config(memory m);
    this.bank = m.copy();
  endfunction

  task run();
    bit  [63:0]  ref_rdata; 
    bit  [63:0]  rel_rdata;
    bit  [63:0]      raddr;
    bit  [63:0]      wdata;
    bit  [63:0]      waddr;
    bit  [63:0]      wmask;
    forever begin
      core_trans trans;
      this.mnt_mb.get(trans);
      if( !trans.wen ) begin  // read
        raddr = {3'b0, trans.addr[63:3]};
        ref_rdata = bank.read(raddr);
        rel_rdata = trans.rdata ;
        total_count ++;
        if( ref_rdata != rel_rdata ) begin
          this.err_count++;
          rpt_pkg::rpt_msg("[CMPFAIL]",
            $sformatf("%0tns %0dth times check but failed, addr:%h, right:%h, wrong:%h\n", $time, this.total_count, trans.addr,ref_rdata, rel_rdata ),
            rpt_pkg::ERROR,
            rpt_pkg::TOP,
            rpt_pkg::LOG);
        end else begin
          rpt_pkg::rpt_msg("[CMPSUCD]",
            $sformatf("%0t %0dth times check and succeed, addr:%h, data:%h \n", $time, this.total_count, trans.addr,rel_rdata),
            rpt_pkg::INFO,
            rpt_pkg::HIGH);
        end
      end else begin        // write
        waddr = {3'b0, trans.addr[63:3]};
        wmask[7:0]   = {8{trans.wstrb[0]}};
        wmask[15:8]  = {8{trans.wstrb[1]}};
        wmask[23:16] = {8{trans.wstrb[2]}};
        wmask[31:24] = {8{trans.wstrb[3]}};
        wmask[39:32] = {8{trans.wstrb[4]}};
        wmask[47:40] = {8{trans.wstrb[5]}};
        wmask[55:48] = {8{trans.wstrb[6]}};
        wmask[63:56] = {8{trans.wstrb[7]}};
        wdata = ( wmask & trans.wdata ) | ( ~wmask & bank.read(waddr) ) ;
        bank.write(waddr, wdata);
      end
    end
  endtask

  function void do_report();
    string s;
    s = "\n---------------------------------------------------------------\n";
    s = {s, "CHECKER SUMMARY \n"}; 
    s = {s, $sformatf("total check count: %0d \n", this.total_count)}; 
    s = {s, $sformatf("total error count: %0d \n", this.err_count)}; 
    s = {s, "---------------------------------------------------------------\n"};
    rpt_pkg::rpt_msg($sformatf("[%s]",this.name), s, rpt_pkg::INFO, rpt_pkg::TOP);
  endfunction

endclass:cache_checker;

`endif
