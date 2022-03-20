.PHONY:vcs verdi clean 

FSDB_NAME = conv_core_tb.fsdb
RUN_VERDI = verdi -f filelist.f  -ssf $(FSDB_NAME) -nologo

vcs:
	vcs -full64 -cpp g++-4.4 -cc gcc-4.4 -sverilog  -timescale=1ns/1ps -f filelist.f -fsdb
	./simv
verdi:
	$(RUN_VERDI)

clean:
	rm -rf *.log  csrc  simv*  *.key *.vpd  DVEfiles coverage *.vdb
