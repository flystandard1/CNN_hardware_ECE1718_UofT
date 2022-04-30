class dense1_env extends uvm_env;
    dense1_active_agent  i_agt;
    dense1_passive_agent o_agt;
    dense1_refm          refm;
    dense1_scbd          scbd;

    uvm_tlm_analysis_fifo #(dense1_input_tr)  agt_refm_fifo;
    uvm_tlm_analysis_fifo #(dense1_output_tr) agt_scbd_fifo;
    uvm_tlm_analysis_fifo #(dense1_output_tr) refm_scbd_fifo;
    
    function new(string name = "dense1_env", uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        i_agt = dense1_active_agent::type_id::create("i_agt",this);
        o_agt = dense1_passive_agent::type_id::create("o_agt",this);
        refm = dense1_refm::type_id::create("refm",this);
        scbd = dense1_scbd::type_id::create("scbd",this);

        agt_refm_fifo = new("agt_refm_fifo", this);
        agt_scbd_fifo = new("agt_scbd_fifo", this);
        refm_scbd_fifo = new("refm_scdb_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        i_agt.ap.connect(agt_refm_fifo.analysis_export);
        refm.port.connect(agt_refm_fifo.blocking_get_export);
        refm.ap.connect(refm_scbd_fifo.analysis_export);
        scbd.exp_port.connect(refm_scbd_fifo.blocking_get_export);
        o_agt.ap.connect(agt_scbd_fifo.analysis_export);
        scbd.act_port.connect(agt_scbd_fifo.blocking_get_export);
    endfunction
    `uvm_component_utils(dense1_env)
endclass


