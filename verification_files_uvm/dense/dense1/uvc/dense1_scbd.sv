class dense1_scbd extends uvm_scoreboard;
    dense1_output_tr expected_queue[$];
    uvm_blocking_get_port #(dense1_output_tr) exp_port;
    uvm_blocking_get_port #(dense1_output_tr) act_port;
    `uvm_component_utils(dense1_scbd)

    function new(string name, uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        exp_port = new("exp_port",this);
        act_port = new("act_port",this);
    endfunction

    task main_phase(uvm_phase phase);
        dense1_output_tr get_expect,get_actual,tmp_tran;
        bit result=1;
        super.main_phase(phase);
        fork
            while(1) begin
                exp_port.get(get_expect);
                expected_queue.push_back(get_expect);
            end
            while(1) begin
                act_port.get(get_actual);
                if(expected_queue.size()>0) begin
                    tmp_tran = expected_queue.pop_front();
                    
                    for(int u=0;u<120;u=u+1) begin
                        if(tmp_tran.dense_sigmoid[u] != get_actual.dense_sigmoid[u]) begin
                            result = 0;
                            `uvm_error(get_type_name(),$sformatf("Error: index=%d,  ref=%d, actual=%d",u, tmp_tran.dense_sigmoid[u], get_actual.dense_sigmoid[u]));
                        end
                        else
                            `uvm_info(get_type_name(),$sformatf("Correct: index=%d, ref=%d, actual=%d",u, tmp_tran.dense_sigmoid[u], get_actual.dense_sigmoid[u]),UVM_HIGH);
                    end

                    if(result) begin
                        `uvm_info(get_type_name(),"Compare SUCCESSFULLY", UVM_LOW)
                    end
                    else begin
                        `uvm_error(get_type_name(),"Compare FAILED");
                        $display("The expected packet is:");
                        tmp_tran.print();
                        $display("The actual packet is:");
                        get_actual.print();
                    end
                end
                else begin
                    `uvm_error(get_type_name(),"Recieved packets from DUT while expected queue is empty!!!")
                    $display("The actual packet is:");
                    get_actual.print();
                end
            end
        join
    endtask
endclass

        
