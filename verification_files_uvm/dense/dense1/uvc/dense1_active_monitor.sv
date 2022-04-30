class dense1_active_monitor extends uvm_monitor;
    virtual dense1_if dif;
    uvm_analysis_port #(dense1_input_tr) ap;
    `uvm_component_utils(dense1_active_monitor)
    function new(string name = "dense1_active_monitor", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual dense1_if)::get(this,"","dif",dif))
            `uvm_fatal(get_type_name(),"virtual interface must be set for dense_if!!!")
        ap = new("ap",this);
    endfunction

    extern task main_phase(uvm_phase phase);
    extern task collect_one_pkt(dense1_input_tr tr_i);
endclass

task dense1_active_monitor::main_phase(uvm_phase phase);
    dense1_input_tr tr_i;
    while(1) begin
        tr_i = new("tr_i");
        collect_one_pkt(tr_i);
        ap.write(tr_i);
    end
endtask
    
task dense1_active_monitor::collect_one_pkt(dense1_input_tr tr_i);
    int i=0;
    while(!dif.frame_start_in)
        @dif.cb;
    while(1) begin
        if(dif.ena) begin 
            tr_i.dense_input[i] = dif.dense_input;
            i = i+1;
        end
        if(dif.frame_end_in)
            break;
        @(dif.cb);
    end
endtask
