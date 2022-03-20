#include <svdpi.h>
#include <math.h>
#include <stdio.h>
void dense_2_model(const int dense_w2[120][10], const int dense_sigmoid[120], const int dense_b2[10], int dense_sum2[10])
{  
    // Dense Layer 2
    int i,j;
    for (i = 0; i < 10; i++)
    {
        dense_sum2[i] = 0;
        for (j = 0; j < 120; j++)
        {
                dense_sum2[i] += dense_w2[j][i] * dense_sigmoid[j];
        }
        //rounding <1,7,8>
        dense_sum2[i] = floor((double)dense_sum2[i] / 256);
        dense_sum2[i] += dense_b2[i];
    }
    
}
