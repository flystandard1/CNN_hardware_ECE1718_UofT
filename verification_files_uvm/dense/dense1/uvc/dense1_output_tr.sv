class dense1_output_tr extends uvm_sequence_item;
    rand bit signed [15:0] dense_sigmoid[120];
    `uvm_object_utils(dense1_output_tr)
    function new(string name = "dense1_output_tr");
        super.new();
    endfunction
endclass
