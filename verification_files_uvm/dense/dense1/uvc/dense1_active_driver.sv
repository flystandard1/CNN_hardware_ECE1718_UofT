class dense1_active_driver extends uvm_driver#(dense1_input_tr);
    virtual dense1_if dif;
    `uvm_component_utils(dense1_active_driver)

    function new(string name = "dense1_driver", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual dense1_if)::get(this,"","dif",dif))
            `uvm_fatal(get_type_name(),"virtual interface must be set!!!")
    endfunction

    task reset_phase(uvm_phase phase);
        phase.raise_objection(this);
        dif.ena <= 1'b0;
        dif.frame_start_in <= 1'b0;
        dif.frame_end_in   <= 1'b0;
        while(!dif.rst_n)
            @(dif.cb);
        phase.drop_objection(this);
    endtask

    task main_phase(uvm_phase phase);
        fork
            while(1) begin
               seq_item_port.get_next_item(req);
               drive_one_pkt(req);
               seq_item_port.item_done();
               repeat(2)
                  @(dif.cb);
            end
            begin
                @(negedge dif.rst_n);
                phase.jump(uvm_reset_phase::get());
            end
        join
    endtask

    task drive_one_pkt(dense1_input_tr tr_i);
	    dif.ena <= 1'b0;
        dif.frame_start_in <= 1'b0;
        dif.frame_end_in   <= 1'b0;
        
        @(dif.cb);
        //generate a packet
        dif.frame_start_in <= 1'b1;
		@(dif.cb);
        dif.frame_start_in <= 1'b0;
        
        for(int u=0; u<980;  u=u+1) begin
            dif.ena = 1'b1;
		    dif.dense_input = req.dense_input[u];
            if(u==979) 
            dif.frame_end_in <= 1'b1;
            @(dif.cb);
            if(u==979)
		    dif.frame_end_in <= 1'b0;
            dif.ena <= 1'b0;
            @(dif.cb);
        end
        dif.frame_end_in <=  1'b0;
        dif.ena <= 1'b0;
        
    endtask

endclass
