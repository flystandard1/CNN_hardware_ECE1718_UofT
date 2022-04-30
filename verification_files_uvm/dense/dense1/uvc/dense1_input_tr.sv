class dense1_input_tr extends uvm_sequence_item;
    rand bit signed [15:0] dense_input[980];

    constraint c{
        foreach(dense_input[u]){
            soft dense_input[u] inside {[-512:512]};
        }
    }

    `uvm_object_utils_begin(dense1_input_tr)
    `uvm_object_utils_end


    function new(string name = "dense1_input_tr");
        super.new();
    endfunction

endclass
