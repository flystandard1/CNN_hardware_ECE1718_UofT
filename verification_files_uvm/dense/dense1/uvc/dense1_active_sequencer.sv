class dense1_active_sequencer extends uvm_sequencer #(dense1_input_tr);
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   `uvm_component_utils(dense1_active_sequencer)
endclass

