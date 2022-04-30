class smoke_sequence extends rand_sequence;

   function new(string name= "smoke_sequence");
      super.new(name);
   endfunction 
   
    `uvm_object_utils(smoke_sequence)
    `uvm_declare_p_sequencer(dense1_active_sequencer)

   virtual task body();
      if(starting_phase != null) 
         starting_phase.raise_objection(this);
      repeat (3) begin
         `uvm_do_with(req,{
            foreach(dense_input[u]){
               dense_input[u] == u;
            }
          })
      end
      #100;
      if(starting_phase != null) 
         starting_phase.drop_objection(this);
   endtask

endclass


class dense1_smoke extends dense1_rand;

   function new(string name = "dense1_smoke", uvm_component parent = null);
      super.new(name,parent);
   endfunction 
   extern virtual function void build_phase(uvm_phase phase); 
   `uvm_component_utils(dense1_smoke)
endclass


function void dense1_smoke::build_phase(uvm_phase phase);
   super.build_phase(phase);
   uvm_config_db#(uvm_object_wrapper)::set(this, 
                                           "env.i_agt.sqr.main_phase", 
                                           "default_sequence", 
                                           smoke_sequence::type_id::get());
   `uvm_info(get_type_name(),"Running dense1_smoke",UVM_LOW)
endfunction
