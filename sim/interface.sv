`ifndef INTERFACE__SV
`define INTERFACE__SV


`include "../rtl/axi_define.v"

interface core_if(input clk, input reset);
  logic           cen   ;
  logic           wen   ;
  logic   [63:0]  addr  ;
  logic   [63:0]  wdata ;
  logic   [63:0]  rdata ;
  logic   [7:0]   wstrb ;
  logic           rsp   ;

	clocking drv_ck @(posedge clk) ;
		//default input #0ns output #1ns;
		output	 cen, wen, addr, wdata, wstrb;
		input rsp, rdata;
	endclocking

	clocking mnt_ck @(posedge clk) ;
		//default input #1ns output #1ns;
		input	 cen, wen, addr, wdata, wstrb;
		input rsp, rdata;
	endclocking

endinterface: core_if

interface axi_arif(input clk, input reset);
  logic   [`AxID_W-1:0]     arid      ;
  logic   [`AxADDR_W-1:0]   araddr    ;
  logic   [`AxLEN_W-1:0]    arlen     ;
  logic   [`AxSIZE_W-1:0]   arsize    ;
  logic   [`AxBURST_W-1:0]  arburst   ;
  logic   [`AxCACHE_W-1:0]  arcache   ;
  logic   [`AxPORT_W-1:0]   arport    ;
  logic   [`AxQOS_W-1:0]    arqos     ;
  logic   [`AxREGION_W-1:0] arregion  ;
  logic                     arlock    ;
  logic                     arvalid   ;
  logic                     arready   ;

	clocking drv_ck @(posedge clk);
		//default input #1ns output #1ns;
		input	 arid, araddr, arlen, arsize, arburst, arcache;
		input	 arport, arqos, arregion, arlock, arvalid;
		output arready;
	endclocking

	clocking mnt_ck @(posedge clk);
		//default input #1ns output #1ns;
		input	 arid, araddr, arlen, arsize, arburst, arcache;
		input	 arport, arqos, arregion, arlock, arvalid;
		input  arready;
	endclocking

endinterface: axi_arif

interface axi_rif(input clk, input reset);
  logic   [`AxID_W-1:0]     rid       ;
  logic   [`AxDATA_W-1:0]   rdata     ;
  logic   [`AxRESP_W-1:0]   rresp     ;
  logic                     rlast     ;
  logic                     rvalid    ;
  logic                     rready    ;

	clocking drv_ck @(posedge clk);
		//default input #1ns output #1ns;
		output	 rid, rdata, rresp, rlast , rvalid;
		input    rready;
	endclocking

	clocking mnt_ck @(posedge clk);
		//default input #1ns output #1ns;
		input	 rid, rdata, rresp, rlast , rvalid;
		input  rready;
	endclocking

endinterface: axi_rif

interface axi_awif(input clk, input reset);
  logic   [`AxID_W-1:0]     awid      ;
  logic   [`AxADDR_W-1:0]   awaddr    ;
  logic   [`AxLEN_W-1:0]    awlen     ;
  logic   [`AxSIZE_W-1:0]   awsize    ;
  logic   [`AxBURST_W-1:0]  awburst   ;
  logic   [`AxCACHE_W-1:0]  awcache   ;
  logic   [`AxPORT_W-1:0]   awport    ;
  logic   [`AxQOS_W-1:0]    awqos     ;
  logic   [`AxREGION_W-1:0] awregion  ;
  logic                     awlock    ;
  logic                     awvalid   ;
  logic                     awready   ;

	clocking drv_ck @(posedge clk);
		//default input #1ns output #1ns;
		input	 awid, awaddr, awlen, awsize, awburst, awcache;
		input	 awport, awqos, awregion, awlock, awvalid;
		output   awready;
	endclocking

	clocking mnt_ck @(posedge clk);
		//default input #1ns output #1ns;
		input	 awid, awaddr, awlen, awsize, awburst, awcache;
		input	 awport, awqos, awregion, awlock, awvalid;
		input  awready;
	endclocking

endinterface: axi_awif

interface axi_wif(input clk, input reset);
  logic   [`AxID_W-1:0]     wid       ;
  logic   [`AxDATA_W-1:0]   wdata     ;
  logic   [`AxWSTRB_W-1:0]  wstrb     ;
  logic                     wlast     ;
  logic                     wvalid    ;
  logic                     wready    ;

	clocking drv_ck @(posedge clk);
		//default input #1ns output #1ns;
		input	 wid, wdata, wstrb, wlast, wvalid ;
		output wready;
	endclocking

	clocking mnt_ck @(posedge clk);
		//default input #1ns output #1ns;
		input	wid, wdata, wstrb, wlast, wvalid ;
		input wready;
	endclocking

endinterface: axi_wif

interface axi_bif(input clk, input reset);
  logic   [`AxID_W-1:0]     bid       ;
  logic   [`AxRESP_W-1:0]   bresp     ;
  logic                     bvalid    ;
  logic                     bready    ;

	clocking drv_ck @(posedge clk);
		//default input #1ns output #1ns;
		output	  bid, bresp, bvalid;
		input	 bready;
	endclocking

	clocking mnt_ck @(posedge clk);
		//default input #1ns output #1ns;
		input	bid, bresp, bvalid;
		input	bready;
	endclocking

endinterface: axi_bif

`endif
