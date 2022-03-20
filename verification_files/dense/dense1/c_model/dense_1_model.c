#include <svdpi.h>
#include <math.h>
#include <stdio.h>

int sigmoid_model(int x); 

void dense_1_model(const int dense_w[980][120], const int dense_input[980], const int dense_b[120], int dense_sigmoid[120])
{  
    // Dense Layer 2
    int i,j;
    int dense_sum[120];
    for (i = 0; i < 120; i++)
    {
        dense_sum[i] = 0;
        for (j = 0; j < 980; j++)
        {
                dense_sum[i] += dense_w[j][i] * dense_input[j];
        }
        //rounding <1,7,8>
        dense_sum[i] = floor((double)dense_sum[i] / 256);
        dense_sum[i] += dense_b[i];
        dense_sigmoid[i] = sigmoid_model(dense_sum[i]);
    }
    
}

int sigmoid_model(int x) {
    int y;
    double x1=x;
        if(x1>-256&&x1<=256)               y =                               floor(7809*x1/32768) + 128;
        else if(x1>-512&&x1<=-256)         y = floor(floor(1530*x1/256)*x1/32768) + floor(9490*x1/32768) + 131;
        else if(x1>-768&&x1<=-512)         y = floor(floor(976 *x1/256)*x1/32768) + floor(7216*x1/32768) + 113;
        else if(x1>-1024&&x1<=-768)        y = floor(floor(442 *x1/256)*x1/32768) + floor(4060*x1/32768) + 76;

        else if(x1>-1280&&x1<=-1024)        y = floor(floor(177 *x1/256)*x1/32768) + floor(1956*x1/32768) + 44;

        else if(x1>1280  && x1<1380)       y = 254;
        else if(x1>=1380 && x1<1536)       y = 255;
        else if(x1>=1536)                  y = 256;

        else if(x1<512&&x1>=256)           y = floor(floor(-1530*x1/256)*x1/32768) + floor(9490*x1/32768) + 125;
        else if(x1<768&&x1>=512)           y = floor(floor(-976 *x1/256)*x1/32768) + floor(7216*x1/32768) + 143;
        else if(x1<1024&&x1>=768)          y = floor(floor(-442 *x1/256)*x1/32768) + floor(4060*x1/32768) + 180;
        else if(x1<=1280&&x1>=1024)         y = floor(floor(-177 *x1/256)*x1/32768) + floor(1956*x1/32768) + 212;

        else if(x1<=-1280  && x1>-1385)   y = 2;
        else if(x1<-1380 && x1>-1536)     y = 1;
        else if(x1<=-1536)                y = 0;
        return y;
}

