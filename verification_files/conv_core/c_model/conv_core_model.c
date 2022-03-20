#include <svdpi.h>
#include <math.h>
#include <stdio.h>

int conv_core_model(const int img[49],const int conv_w[49], const int conv_b){
    int  conv_layer = 0;
    long long conv_layer_mid = 0;
    int k,l;
    for (k = 0; k < 7; k++)
    {
            for (l = 0; l < 7; l++)
            {
                    conv_layer_mid += (long long)(img[k*7+l]*256) * (long long)conv_w[k*7+l]; 
            }
    }
    //printf("%d",conv_layer_mid);
    conv_layer_mid += conv_b * 256;
    conv_layer = floor((double)conv_layer_mid/256);
    if(conv_layer>32767) conv_layer = 32767;
    else if(conv_layer<-32768) conv_layer = -32768;

    return conv_layer;
}
