#include <svdpi.h>
#include <stdio.h>
// MAX Pooling (max_pooling, max_layer)
void maxpooling_model(const signed int sig_layer[5][28][28],signed int max_layer[5][14][14]){
    signed int cur_max = 0;
    int max_i = 0, max_j = 0;
    int i,j,k,l;
    int filter_dim;
    for (filter_dim = 0; filter_dim < 5; filter_dim++)
    {
            for (i = 0; i < 28; i += 2)
            {
                    for (j = 0; j < 28; j += 2)
                    {
                            max_i = i;
                            max_j = j;
                            cur_max = sig_layer[filter_dim][i][j];
                            for (k = 0; k < 2; k++)
                            {
                                    for (l = 0; l < 2; l++)
                                    {
                                            if (sig_layer[filter_dim][i + k][j + l] > cur_max)
                                            {
                                                    max_i = i + k;
                                                    max_j = j + l;
                                                    cur_max = sig_layer[filter_dim][max_i][max_j];
                                            }
                                    }
                            }
                            max_layer[filter_dim][i / 2][j / 2] = cur_max;
                            //printf("i=%d, j=%d, cur_max=%d, pix1=%d, pix2=%d, pix3=%d, pix4=%d\n",i,j,cur_max,sig_layer[filter_dim][i+0][j+0],sig_layer[filter_dim][i+0][j+1],sig_layer[filter_dim][i+1][j],sig_layer[filter_dim][i + 1][j + 1]);

                    }
            }
    }
}


