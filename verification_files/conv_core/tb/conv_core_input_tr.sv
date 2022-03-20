class conv_core_input_tr;
    rand int signed ima[49];
    rand int signed wei[49];
    rand int signed bias;

    //special case
    constraint c{
        foreach(ima[u]){
            ima[u] == 1;
        }
        foreach(wei[j]){
            wei[j] == 256; //<1,7,8>
        }
        bias == 256; //<1,7,8>
    }

    //random case
    //constraint c{
    //    foreach(ima[u]){
    //        ima[u] inside {[0:255]};
    //    }
    //    foreach(wei[j]){
    //        wei[j] inside {[-256:256]}; //<1,7,8>
    //        //wei[j] inside {[-32:32]}; //<1,7,8>
    //    }
    //    bias inside {[-256:256]}; //<1,7,8>
    //}

endclass
