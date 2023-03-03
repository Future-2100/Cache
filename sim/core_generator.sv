
`ifndef CORE_GENERATOR__SV
`define CORE_GENERATOR__SV

class core_generator;

  local string name;
  
  typedef enum {READ, WRITE} option_t;
  
  typedef struct {
    option_t     option      ;
	bit  [31:0]  repeat_time ;
	bit  [63:0]  begin_addr  ;
  } mode_s;

  mode_s mode[];
  
  bit  [63:0]  j ;
  
  mailbox #(core_trans) drv_req_mb;
  mailbox #(core_trans) drv_rsp_mb;

  function new(string name = "core_generator");
    this.name = name ;
    drv_req_mb = new();
    drv_rsp_mb = new();
  endfunction




  task run();
	
	foreach(this.mode[i]) begin
	  this.j = mode[i].begin_addr;
	  if(mode[i].option == READ) begin
		repeat(mode[i].repeat_time)  begin 
          core_trans trans;
          trans = new();
          assert( trans.randomize() with { 
	        cen    ==  1'b1 ;
            addr   ==  j ;
            wen    ==  1'b0 ;
          })
            else $fatal("[RAND ERR] : core generator rand error!");
          this.j += 8 ;
          drv_req_mb.put(trans);
          drv_rsp_mb.get(trans);
          assert(trans.rsp == 1)
            else $error("[RSP ERROR] : core generator rand error!");
		end
	  end else if(mode[i].option == WRITE) begin
	    repeat(mode[i].repeat_time)  this.write();
	  end
	  $display("====================================================\n");
	end
	
	clear();
  endtask


  task write();
      core_trans trans;
      trans = new();
      assert( trans.randomize() with { 
	    cen    ==  1'b1 ;
        addr   ==  j ;
        wen    ==  1'b1 ;
        wdata  ==  j ;
        //wstrb  ==  8'hff;
      })
        else $fatal("[RAND ERR] : core generator rand error!");
      this.j += 8 ;
      drv_req_mb.put(trans);
      drv_rsp_mb.get(trans);
      assert(trans.rsp == 1)
        else $error("[RSP ERROR] : core generator rand error!");
  endtask
  
    task clear();
      core_trans trans;
      trans = new();
      assert( trans.randomize() with { 
	    cen    ==  1'b0 ;
        addr   == 64'b0 ;
        wen    ==  1'b0 ;
        wdata  == 64'b0 ;
        wstrb  ==  8'h0 ;
      })
        else $fatal("[RAND ERR] : core generator rand error!");
      drv_req_mb.put(trans);

  endtask

endclass

`endif

