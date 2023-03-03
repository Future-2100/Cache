
INCDIR = ./include
INCDIR += ./sim
INCDIR += ./sim/core_dir
INCDIR += ./sim/axi_dir
INC = $(addprefix +incdir+, $(INCDIR))

all:com sim

com:
	vcs -full64 -sverilog -debug_acc+all -timescale=1ns/1ns -f filelist -l com.log $(INC)

sim:./simv
	./simv +TESTNAME=first_test -l sim.log

run_dve:
	dve -vpd vcdplus.vpd &

debug:
	verdi -sv -f filelist -top tb \
		-ssf tb.fsdb -nologo

clean:
	@rm -rf *.vpd csrc *.log *.key *.vdb  DVEfiles simv.daidir simv *.conf *.rc verdiLog *.fsdb

