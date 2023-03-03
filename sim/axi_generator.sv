
`ifndef AXI_GENERATOR__SV
`define AXI_GENERATOR__SV


class memory;

  local string name;

  rand bit [63:0] unit[64'h11ff_ffff:64'h1000_0000];

  function new(string name = "memory");
    this.name = name ;
  endfunction

  function void write(bit [63:0] addr, bit [63:0] data);
    unit[addr] = data ;
  endfunction

  function bit [63:0]  read(bit [63:0] addr );
    return unit[addr] ;
  endfunction

  function memory copy();
    memory m = new();
    foreach(m.unit[i]) begin
      m.unit[i] = this.unit[i];
    end
    return m ;
  endfunction
  
endclass


class axi_generator;

  local string name;

  memory  bank;

  semaphore access;

  mailbox  #(axi_artrans)  arreq_mb;
  mailbox  #(axi_artrans)  arrsp_mb;
  mailbox  #(axi_rtrans)    rreq_mb;
  mailbox  #(axi_rtrans)    rrsp_mb;
  mailbox  #(axi_awtrans)  awreq_mb;
  mailbox  #(axi_awtrans)  awrsp_mb;
  mailbox  #(axi_wtrans)    wreq_mb;
  mailbox  #(axi_wtrans)    wrsp_mb;
  mailbox  #(axi_btrans)    breq_mb;
  mailbox  #(axi_btrans)    brsp_mb;

  mailbox #(axi_awtrans)  awfifo_mb;
  mailbox #(axi_wtrans)    wfifo_mb;

  function new(string name="axi_generator");
    this.name = name ;
    this.bank= new({name, ".memory"});
    assert(bank.randomize())
      else $error("[RAND ERR]: memory randomize error!");
    this.arreq_mb = new();  
    this.arrsp_mb = new(); 
    this.rreq_mb  = new(); 
    this.rrsp_mb  = new(); 
    this.awreq_mb = new(); 
    this.awrsp_mb = new(); 
    this.wreq_mb  = new();  
    this.wrsp_mb  = new(); 
    this.breq_mb  = new(); 
    this.brsp_mb  = new(); 
    this.awfifo_mb= new();
    this.wfifo_mb = new();
    this.access   = new(1);
  endfunction

  task run();
    fork
      read_run();
      write_run();
    join
  endtask

  task write_run();
    fork
      aw_run();
      w_run();
      b_run();
    join
  endtask

  task aw_run();
    forever begin
      axi_awtrans awtrans;
      awtrans = new();
      assert(awtrans.randomize())
        else $fatal("[RAND FAIL]: aw trans rand failure!");
      this.awreq_mb.put(awtrans);
      this.awrsp_mb.get(awtrans);
      assert(awtrans.rsp)
        else $error("[RSP ERR] %0tns awtrans response error!", $time);
      awfifo_mb.put(awtrans);
    end
  endtask

  task w_run();
    forever begin
      axi_wtrans wtrans;
      wtrans = new();
      assert(wtrans.randomize())
        else $fatal("[RAND FAIL]: w trans rand failure!");
      this.wreq_mb.put(wtrans);
      this.wrsp_mb.get(wtrans);
      assert(wtrans.rsp)
        else $error("[RSP ERR] %0tns wtrans response error!", $time);
      wfifo_mb.put(wtrans);
    end
  endtask

  task b_run();
    axi_awtrans awtrans;
    axi_wtrans   wtrans;
    axi_btrans   btrans;
    bit [63:0]  wdata[];
    bit [63:0]  waddr  ;
    bit [7:0]   wstrb[];
    bit [63:0] wmask;
    bit [63:0] wdatain ;
    int i=0 ;
    forever begin
      awfifo_mb.get(awtrans);
      assert( awtrans.awsize  ==  3'b011 &&
              awtrans.awburst ==  2'b01  &&
              awtrans.awaddr[2:0]  == 3'b0 &&
			  awtrans.awlen == 7
            )
        else begin
			$error("[AWTRANS ERR]: %0tns : awtrans received error!", $time); 
		end
      wdata = new[awtrans.awlen + 1];
      wstrb = new[awtrans.awlen + 1];
      waddr = {3'b0, awtrans.awaddr[63:3] } ;
      while(i < awtrans.awlen + 1 ) begin
        wfifo_mb.get(wtrans);
        if(wtrans.wid != awtrans.awid) begin
          wfifo_mb.put(wtrans);
          rpt_pkg::rpt_msg("[b_run diff id]",
	        wtrans.sprint,
	    	rpt_pkg::INFO ,
	    	rpt_pkg::HIGH
	      );
        end else begin
          wdata[i] = wtrans.wdata;
          wstrb[i] = wtrans.wstrb;
          if( i == awtrans.awlen ) begin
            assert(wtrans.wlast==1'b1)
              else $error("[WTRANS ERR]:awlen is not match the wlast!");
          end
          i++ ;
        end
      end
	  i=0;
	  
      this.access.get(1);
      foreach(wdata[j]) begin
         wmask[7:0]   = {8{wstrb[j][0]}} ;
         wmask[15:8]  = {8{wstrb[j][1]}} ;
         wmask[23:16] = {8{wstrb[j][2]}} ;
         wmask[31:24] = {8{wstrb[j][3]}} ;
         wmask[39:32] = {8{wstrb[j][4]}} ;
         wmask[47:40] = {8{wstrb[j][5]}} ;
         wmask[55:48] = {8{wstrb[j][6]}} ;
         wmask[63:56] = {8{wstrb[j][7]}} ;
         wdatain = (wmask & wdata[j]) | (~wmask & bank.read(waddr + j));
         bank.write(waddr+j, wdatain);
      end
      this.access.put(1);

      btrans = new();
      assert(btrans.randomize())
        else $fatal("[RAND FAIL] b trans randomization failure!");
      btrans.bresp = 0;
      btrans.bid = awtrans.awid;
      this.breq_mb.put(btrans);
      this.brsp_mb.get(btrans);
      assert(btrans.rsp==1)
        else $error("[RSP ERR] %0t btrans response received error !", $time);
    end
  endtask

  task read_run();
    bit [63:0] addr;
    axi_rtrans   rtrans ;
    forever begin
      axi_artrans  artrans;
      artrans = new();
      assert(artrans.randomize() with { nidles== 20; })
        else $error("[RAND ERR] : artrans randomize error");
      this.arreq_mb.put(artrans);
      this.arrsp_mb.get(artrans);
      assert(artrans.rsp)
        else $error("[RSP ERR]: %0t artrans response error!", $time);
      assert(artrans.araddr[2:0] == 3'b0);
      addr = { 3'b0, artrans.araddr[63:3] } ;
      access.get(1);
      rtrans = new();
      rtrans.rid = artrans.arid;
      rtrans.rdata = new[artrans.arlen + 1];
      foreach(rtrans.rdata[i]) begin
        assert( (addr + i) inside {[64'h1000_0000:64'h11ff_ffff]} ) ;
        rtrans.rdata[i] = bank.read(addr + i);
      end
      rtrans.rresp = 0;
      access.put(1);
      assert(rtrans.randomize() with { nidles== 20; })
        else $error("[RAND ERR]: rtrans randomize error!");
      this.rreq_mb.put(rtrans);
      this.rrsp_mb.get(rtrans);
      assert(rtrans.rsp)
        else $error("[RSP ERR] %0t rtrans response error !", $time);
    end
  endtask

endclass:axi_generator

`endif
