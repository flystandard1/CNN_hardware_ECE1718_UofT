.PHONY:vcs verdi clean 

tc = dense1_rand
vb = UVM_MEDIUM

UVM_HOME = /home/wugxfly/Documents/uvm/uvm-1.1d
FSDB_NAME = dense_1.fsdb
RUN_VERDI = verdi -f filelist.f  -ssf $(FSDB_NAME) -nologo

vcs:
	vcs -full64 -cpp g++-4.4 -cc gcc-4.4 +acc +vpi -sverilog $(UVM_HOME)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS -timescale=1ns/1ps -f filelist.f -fsdb
	./simv +UVM_TESTNAME=$(tc) +UVM_VERBOSITY=$(vb)

verdi:
	$(RUN_VERDI)

clean:
	rm -rf *.log  csrc  simv*  *.key *.vpd  DVEfiles coverage *.vdb
