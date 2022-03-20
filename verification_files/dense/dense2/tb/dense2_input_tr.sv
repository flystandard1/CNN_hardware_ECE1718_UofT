class dense2_input_tr;
    rand int signed dense_sigmoid[120];

    ////special case
    //constraint c{
    //    foreach(dense_sigmoid[u]){
    //        dense_sigmoid[u] == u;

    //    }
    //}

    //random case
    constraint c{
        foreach(dense_sigmoid[u]){
            dense_sigmoid[u] inside {[0:255]};

        }
    }

endclass
