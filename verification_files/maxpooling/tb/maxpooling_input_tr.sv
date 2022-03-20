class maxpooling_input_tr;
    rand int signed sig_layer_in[5][28][28];

    //special case
    constraint c{
        foreach(sig_layer_in[u]){
            foreach(sig_layer_in[u][i]){
                foreach(sig_layer_in[u][i][j]){
                    sig_layer_in[u][i][j] == u+i+j-100;
                }
            }
        }
    }

    //random case
    //constraint c{
    //    foreach(sig_layer_in[u]){
    //        foreach(sig_layer_in[u][i]){
    //            foreach(sig_layer_in[u][i][j]){
    //                sig_layer_in[u][i][j] inside {[-32768:32767]};
    //            }
    //        }
    //    }
    //}

endclass
