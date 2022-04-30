import "DPI-C" function void dense_1_model(input int signed dense_w[980][120], input int signed dense_input[980], input int signed dense_b[120], output int signed dense_sigmoid[120]);

class dense1_refm extends uvm_component;
    uvm_blocking_get_port #(dense1_input_tr) port;
    uvm_analysis_port #(dense1_output_tr) ap;
    virtual interface mem_if memif;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    extern function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    `uvm_component_utils(dense1_refm);
endclass

function void dense1_refm::build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port",this);
    ap = new("ap",this);
    if(!uvm_config_db#(virtual mem_if)::get(this,"","memif",memif))
        `uvm_fatal(get_type_name(),"virtual interface must be set for mem_if!!!")
endfunction

task dense1_refm::main_phase(uvm_phase phase);
    dense1_input_tr  tr_i;
    dense1_output_tr tr_o_ref;
    int i1,i2;
    int signed dense_input_int[980];
    int signed dense_sigmoid_int[120];
    super.main_phase(phase);
    while(1) begin
        port.get(tr_i);
        tr_o_ref = new("tr_o_ref");

        for(i1=0;i1<980;i1=i1+1) begin
            dense_input_int[i1] = tr_i.dense_input[i1];
        end

        dense_1_model(
            .dense_w(memif.dense_w),
            .dense_input(dense_input_int),
            .dense_b(memif.dense_b),
            .dense_sigmoid(dense_sigmoid_int)
            );
        for(i2=0;i2<120;i2=i2+1) begin
            tr_o_ref.dense_sigmoid[i2] = dense_sigmoid_int[i2];
        end
        ap.write(tr_o_ref);
    end
endtask




