class dense1_passive_monitor extends uvm_monitor;
    virtual dense1_if dif;
    uvm_analysis_port #(dense1_output_tr) ap;
    `uvm_component_utils(dense1_passive_monitor)
    function new(string name="dense1_passive_monitor", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual dense1_if)::get(this,"","dif",dif))
            `uvm_fatal(get_type_name(),"virtual interface must be set for dense_if!!!")
        ap = new("ap",this);
    endfunction

    task collect_one_pkt(dense1_output_tr tr_o);
        int i=0;
        while(!dif.frame_start_out)
            @dif.cb;
        while(1) begin
            if(dif.valid) begin 
                tr_o.dense_sigmoid[i]=$signed(dif.dense_sigmoid_out);
                i = i+1;
            end
            if(dif.frame_end_out) begin
                break;
            end
            @(dif.cb);
        end
    endtask

    task main_phase(uvm_phase phase);
        dense1_output_tr tr_o;
        while(1) begin
            tr_o = new("tr_o");
            collect_one_pkt(tr_o);
            ap.write(tr_o);
        end
    endtask
endclass
    
