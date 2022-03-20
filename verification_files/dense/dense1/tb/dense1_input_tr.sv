class dense1_input_tr;
    rand int signed dense_input[980];

    //special case
    //constraint c{
    //    foreach(dense_input[u]){
    //        dense_input[u] == u;

    //    }
    //}

    //random case
    constraint c{
        foreach(dense_input[u]){
            dense_input[u] inside {[-512:512]};

        }
    }

endclass
