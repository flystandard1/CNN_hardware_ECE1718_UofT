class dense1_active_agent extends uvm_agent;
    dense1_active_sequencer sqr;
    dense1_active_driver    drv;
    dense1_active_monitor   mon;

    uvm_analysis_port #(dense1_input_tr) ap;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    `uvm_component_utils(dense1_active_agent)
endclass

function void dense1_active_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    sqr = dense1_active_sequencer::type_id::create("sqr",this);
    drv = dense1_active_driver::type_id::create("drv",this);
    mon = dense1_active_monitor::type_id::create("mon",this);
endfunction

function void dense1_active_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
    ap=mon.ap;
endfunction


