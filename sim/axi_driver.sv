`ifndef AXI_DRIVER__SV
`define AXI_DRIVER__SV

class axi_driver;

  local string name;

  virtual axi_arif arif;
  virtual axi_rif   rif;
  virtual axi_awif awif;
  virtual axi_wif   wif;
  virtual axi_bif   bif;

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

  function new(string name = "axi_driver");
    this.name = name ;
  endfunction

  function void set_interface(virtual axi_arif arif, virtual axi_rif rif , virtual axi_awif awif, virtual axi_wif wif, virtual axi_bif bif);
    if(arif == null || rif == null || awif == null || wif == null || bif == null)
      $error({name, " : arif or rif is null!"});
    else begin
      this.arif = arif ;
      this.rif  =  rif ;
      this.awif = awif ;
      this.wif  =  wif ;
      this.bif  =  bif ;
    end
  endfunction

  task run();
    fork
      this.ardrive();
      this.rdrive();
      this.awdrive();
      this.wdrive();
      this.bdrive();
      this.reset();
    join
  endtask

  task ardrive();
    @(posedge arif.reset);
    forever begin
      axi_artrans req;
      arreq_mb.get(req);
      @(negedge arif.clk iff(arif.arvalid && !arif.arready));
      repeat(req.nidles) @(posedge arif.clk);
      arif.drv_ck.arready <= 1'b1;
      fork begin
        @(posedge arif.clk); 
        arif.drv_ck.arready <= 1'b0;
      end
      join_none
	  @(negedge arif.clk);
      req.arid      = arif.arid     ;
      req.araddr    = arif.araddr   ;
      req.arlen     = arif.arlen    ;
      req.arsize    = arif.arsize   ;
      req.arburst   = arif.arburst  ;
      req.arcache   = arif.arcache  ;
      req.arport    = arif.arport   ;
      req.arqos     = arif.arqos    ;
      req.arregion  = arif.arregion ;
      req.arlock    = arif.arlock   ;
      req.rsp = 1 ;
      arrsp_mb.put(req);
    end
  endtask

  task rdrive();
    @(posedge rif.reset);
    forever begin
      axi_rtrans req;
      this.rreq_mb.get(req);
      repeat(req.nidles) @(posedge rif.clk);
      foreach(req.rdata[i]) begin
        @(posedge rif.clk);
        rif.drv_ck.rvalid <= 1'b1;
        rif.drv_ck.rid    <= req.rid ;
        rif.drv_ck.rdata  <= req.rdata[i] ;
        rif.drv_ck.rresp  <= req.rresp    ;
        if(i == req.rdata.size - 1)
          rif.drv_ck.rlast <= 1'b1;
        else
          rif.drv_ck.rlast <= 1'b0;
      end
      fork begin
        @(posedge rif.clk);
        rif.drv_ck.rvalid <= 1'b0 ;
        rif.drv_ck.rid    <=  'b0 ;
        rif.drv_ck.rdata  <=  'b0 ;
        rif.drv_ck.rresp  <=  'b0 ;
        rif.drv_ck.rlast  <=  'b0 ;
      end
      join_none
      req.rsp = 1 ;
      this.rrsp_mb.put(req);
    end
  endtask

  task awdrive();
    @(posedge awif.reset);
    forever begin
      axi_awtrans req;
      this.awreq_mb.get(req);
	  @(negedge awif.clk iff(awif.awvalid && !awif.awready));
      repeat(req.nidles) @(posedge awif.clk);
      awif.drv_ck.awready <= 1'b1;
      fork begin
        @(posedge awif.clk);
        awif.drv_ck.awready <= 1'b0;
      end
      join_none
	  @(negedge awif.clk);
	  req.awid     = awif.awid     ;
	  req.awaddr   = awif.awaddr   ;
	  req.awlen    = awif.awlen    ;
	  req.awsize   = awif.awsize   ;
	  req.awburst  = awif.awburst  ;
	  req.awcache  = awif.awcache  ;
	  req.awport   = awif.awport   ;
	  req.awqos    = awif.awqos    ;
	  req.awregion = awif.awregion ;
	  req.awlock   = awif.awlock   ;
      req.rsp = 1 ;
      this.awrsp_mb.put(req);
    end
  endtask

  task wdrive();
    @(posedge wif.reset);
    forever begin
      axi_wtrans req;
      this.wreq_mb.get(req);
      @(negedge wif.clk iff(wif.wvalid && !wif.wready));
      repeat(req.nidles) @(posedge wif.clk);
      wif.drv_ck.wready <= 1'b1;
      fork begin
        @(posedge wif.clk);
        wif.drv_ck.wready <= 1'b0;
	  end
      join_none
	  @(negedge wif.clk);
	  req.wid   = wif.wid   ;
	  req.wdata = wif.wdata ;
	  req.wstrb = wif.wstrb ;
	  req.wlast = wif.wlast ;
      req.rsp   = 1 ;
      this.wrsp_mb.put(req);
    end
  endtask

  task bdrive();
    @(posedge bif.reset);
    forever begin
      axi_btrans req;
      breq_mb.get(req);
      repeat(req.nidles) @(posedge bif.clk);
      bif.drv_ck.bvalid   <= 1'b1;
	  bif.drv_ck.bid      <= req.bid   ;
	  bif.drv_ck.bresp    <= req.bresp ;
      fork begin
        @(posedge bif.clk);
        bif.drv_ck.bvalid <= 1'b0 ;
		bif.drv_ck.bid    <=  'b0 ;
	    bif.drv_ck.bresp  <=  'b0 ;
      end
      join_none
      req.rsp = 1 ;
      brsp_mb.put(req);
    end
  endtask

  task reset();
    forever begin
      @(posedge arif.clk iff(!arif.reset));
      arif.drv_ck.arready <= 1'b0 ;
      rif.drv_ck.rid      <=  'b0 ;
      rif.drv_ck.rresp    <=  'b0 ;
      rif.drv_ck.rdata    <=  'h0 ;
      rif.drv_ck.rvalid   <= 1'b0 ;
      rif.drv_ck.rlast    <= 1'b0 ;
      awif.drv_ck.awready <= 1'b0 ;
      wif.drv_ck.wready   <= 1'b0 ;
      bif.drv_ck.bid      <=  'b0 ;
      bif.drv_ck.bresp    <=  'b0 ;
      bif.drv_ck.bvalid   <=  'b0 ; 
    end
  endtask

endclass:axi_driver

`endif
