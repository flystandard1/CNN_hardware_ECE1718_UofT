class dense1_passive_agent extends uvm_agent ;

   dense1_passive_monitor    mon;
   
   uvm_analysis_port #(dense1_output_tr)  ap;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);

   `uvm_component_utils(dense1_passive_agent)
endclass 

function void dense1_passive_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = dense1_passive_monitor::type_id::create("mon",this);
endfunction

function void dense1_passive_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ap=mon.ap;
endfunction


