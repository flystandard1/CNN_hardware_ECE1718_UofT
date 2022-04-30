class rand_sequence extends uvm_sequence #(dense1_input_tr);
   dense1_input_tr m_trans;

   function new(string name= "rand_sequence");
      super.new(name);
   endfunction 
   
    `uvm_object_utils(rand_sequence)
    `uvm_declare_p_sequencer(dense1_active_sequencer)

   virtual task body();
      if(starting_phase != null) 
         starting_phase.raise_objection(this);
      repeat (3) begin
         `uvm_do(req)
      end
      #100;
      if(starting_phase != null) 
         starting_phase.drop_objection(this);
   endtask

endclass


class dense1_rand extends dense1_base_test;

   function new(string name = "dense1_rand", uvm_component parent = null);
      super.new(name,parent);
   endfunction 
   extern virtual function void build_phase(uvm_phase phase); 
   `uvm_component_utils(dense1_rand)
endclass


function void dense1_rand::build_phase(uvm_phase phase);
   super.build_phase(phase);

   uvm_config_db#(uvm_object_wrapper)::set(this, 
                                           "env.i_agt.sqr.main_phase", 
                                           "default_sequence", 
                                           rand_sequence::type_id::get());
   `uvm_info(get_type_name(),"Running dense1_rand",UVM_LOW)
endfunction
