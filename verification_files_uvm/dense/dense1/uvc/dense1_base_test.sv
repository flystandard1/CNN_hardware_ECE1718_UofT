class dense1_base_test extends uvm_test;

   dense1_env         env;
   
   function new(string name = "dense1_base_test", uvm_component parent = null);
      super.new(name,parent);
   endfunction
   
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void report_phase(uvm_phase phase);
   `uvm_component_utils(dense1_base_test)
   extern virtual task main_phase(uvm_phase phase);
endclass


function void dense1_base_test::build_phase(uvm_phase phase);
   super.build_phase(phase);
   env  =  dense1_env::type_id::create("env", this); 
endfunction



function void dense1_base_test::report_phase(uvm_phase phase);
   uvm_report_server server;
   int err_num;
   super.report_phase(phase);

   server = get_report_server();
   err_num = server.get_severity_count(UVM_ERROR);

   if (err_num != 0) begin
      `uvm_error(get_type_name(),"TEST CASE FAILED");
   end
   else begin
      `uvm_info(get_type_name(),"TEST CASE PASSED",UVM_LOW);
   end
endfunction
   
task dense1_base_test::main_phase(uvm_phase phase);
    phase.phase_done.set_drain_time(this, 200000);
endtask
