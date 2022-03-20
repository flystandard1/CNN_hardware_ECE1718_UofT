// fixed point c model

#include <iostream>
#include <cmath>
#include <cstdlib>
#include <sstream>
#include <fstream>

const int FRACBITS = 8;
const int FRACBITS_CONV_W = 6;

const int filter_size = 7;
// const double eta = 0.01;
const int batch_size = 200;

unsigned char data_train[60000][784];
unsigned char data_test[10000][784];
unsigned char label_train[60000];
unsigned char label_test[10000];

// Weights
double conv_w[5][7][7];
double conv_b[5][28][28];
double dense_w[980][120];
double dense_b[120];
double dense_w2[120][10];
double dense_b2[10];

// 16-bit fixed-point weights
short conv_w_fp[5][7][7];
short conv_b_fp[5][28][28];
short dense_w_fp[980][120];
short dense_b_fp[120];
short dense_w2_fp[120][10];
short dense_b2_fp[10];

// Layers
int conv_layer[5][28][28];
int sig_layer[5][28][28];
int max_layer[5][14][14];
char max_pooling[5][28][28];
int dense_input[980];
int dense_sum[120];
int dense_sigmoid[120];
int dense_sum2[10];
int dense_softmax[10];

// 16-bit fixed-point layers
short conv_layer_fp[5][28][28];
short sig_layer_fp[5][28][28];
short max_layer_fp[5][14][14];
short dense_input_fp[980];
short dense_sum_fp[120];
short dense_sigmoid_fp[120];
short dense_sum2_fp[10];
short dense_softmax_fp[10];

/* ************************************************************ */
/* Helper functions */
short sigmoid_test0(short x)
{
        short y;
        if (x > short(-1 * pow(2, FRACBITS)) && x <= short(1 * pow(2, FRACBITS)))
                y = ((short(0.2383 * pow(2, FRACBITS)) * x) >> FRACBITS) + short(0.5000 * pow(2, FRACBITS));
        if (x > short(-2 * pow(2, FRACBITS)) && x <= short(-1 * pow(2, FRACBITS)))
                y = ((short(0.0467 * pow(2, FRACBITS)) * x * x) >> FRACBITS * 2) + ((short(0.2896 * pow(2, FRACBITS)) * x) >> FRACBITS) + short(0.5118 * pow(2, FRACBITS));
        if (x > short(-3 * pow(2, FRACBITS)) && x <= short(-2 * pow(2, FRACBITS)))
                y = ((short(0.0298 * pow(2, FRACBITS)) * x * x) >> FRACBITS * 2) + ((short(0.2202 * pow(2, FRACBITS)) * x) >> FRACBITS) + short(0.4400 * pow(2, FRACBITS));
        if (x > short(-4 * pow(2, FRACBITS)) && x <= short(-3 * pow(2, FRACBITS)))
                y = ((short(0.0135 * pow(2, FRACBITS)) * x * x) >> FRACBITS * 2) + ((short(0.1239 * pow(2, FRACBITS)) * x) >> FRACBITS) + short(0.2969 * pow(2, FRACBITS));
        if (x > short(-5 * pow(2, FRACBITS)) && x <= short(-4 * pow(2, FRACBITS)))
                y = ((short(0.0054 * pow(2, FRACBITS)) * x * x) >> FRACBITS * 2) + ((short(0.0597 * pow(2, FRACBITS)) * x) >> FRACBITS) + short(0.1703 * pow(2, FRACBITS));
        if (x <= short(-5 * pow(2, FRACBITS)))
                y = 0;

        // if (x > short(-5.03 * pow(2, FRACBITS)) && x <= short(-5 * pow(2, FRACBITS)))
        //         y = 0.0066;
        // if (x > short(-5.2 * pow(2, FRACBITS)) && x <= short(-5.03 * pow(2, FRACBITS)))
        //         y = 0.0060;
        // if (x > short(-5.41 * pow(2, FRACBITS)) && x <= short(-5.2 * pow(2, FRACBITS)))
        //         y = 0.0050;
        // if (x > short(-5.66 * pow(2, FRACBITS)) && x <= short(-5.41 * pow(2, FRACBITS)))
        //         y = 0.0040;
        // if (x > short(-6 * pow(2, FRACBITS)) && x <= short(-5.66 * pow(2, FRACBITS)))
        //         y = 0.0030;
        // if (x > short(-6.53 * pow(2, FRACBITS)) && x <= short(-6 * pow(2, FRACBITS)))
        //         y = 0.0020;
        // if (x > short(-7.6 * pow(2, FRACBITS)) && x <= short(-6.53 * pow(2, FRACBITS)))
        //         y = 0.0010;
        // if (x <= short(-7.6 * pow(2, FRACBITS)))
        //         y = 0;

        if (x > short(1 * pow(2, FRACBITS)) && x <= short(2 * pow(2, FRACBITS)))
                y = ((short(-0.0467 * pow(2, FRACBITS)) * x * x) >> FRACBITS * 2) + ((short(0.2896 * pow(2, FRACBITS)) * x) >> FRACBITS) + short(0.4882 * pow(2, FRACBITS));
        if (x > short(2 * pow(2, FRACBITS)) && x <= short(3 * pow(2, FRACBITS)))
                y = ((short(-0.0298 * pow(2, FRACBITS)) * x * x) >> FRACBITS * 2) + ((short(0.2202 * pow(2, FRACBITS)) * x) >> FRACBITS) + short(0.5600 * pow(2, FRACBITS));
        if (x > short(3 * pow(2, FRACBITS)) && x <= short(4 * pow(2, FRACBITS)))
                y = ((short(-0.0135 * pow(2, FRACBITS)) * x * x) >> FRACBITS * 2) + ((short(0.1239 * pow(2, FRACBITS)) * x) >> FRACBITS) + short(0.7030 * pow(2, FRACBITS));
        if (x > short(4 * pow(2, FRACBITS)) && x <= short(5 * pow(2, FRACBITS)))
                y = ((short(-0.0054 * pow(2, FRACBITS)) * x * x) >> FRACBITS * 2) + ((short(0.0597 * pow(2, FRACBITS)) * x) >> FRACBITS) + short(0.8297 * pow(2, FRACBITS));
        if (x > short(5 * pow(2, FRACBITS)))
                y = 1 * pow(2, FRACBITS);

        // if (x > short(5 * pow(2, FRACBITS)) && x <= short(5.0218 * pow(2, FRACBITS)))
        //         y = 0.9930;
        // if (x > short(5.0218 * pow(2, FRACBITS)) && x <= short(5.1890 * pow(2, FRACBITS)))
        //         y = 0.9940;
        // if (x > short(5.1890 * pow(2, FRACBITS)) && x <= short(5.3890 * pow(2, FRACBITS)))
        //         y = 0.9950;
        // if (x > short(5.3890 * pow(2, FRACBITS)) && x <= short(5.6380 * pow(2, FRACBITS)))
        //         y = 0.9960;
        // if (x > short(5.6380 * pow(2, FRACBITS)) && x <= short(5.9700 * pow(2, FRACBITS)))
        //         y = 0.9970;
        // if (x > short(5.9700 * pow(2, FRACBITS)) && x <= short(6.4700 * pow(2, FRACBITS)))
        //         y = 0.9980;
        // if (x > short(6.4700 * pow(2, FRACBITS)) && x <= short(7.5500 * pow(2, FRACBITS)))
        //         y = 0.9990;
        // if (x > short(7.5500 * pow(2, FRACBITS)))
        //         y = 1;
        return y;
}

short sigmoid_test(short x)
{
        short y;
        double x1 = x;
        if (x1 > -256 && x1 <= 256)
                y = floor(7809 * x1 / 32768) + 128;
        else if (x1 > -512 && x1 <= -256)
                y = floor(floor(1530 * x1 / 256) * x1 / 32768) + floor(9490 * x1 / 32768) + 131;
        else if (x1 > -768 && x1 <= -512)
                y = floor(floor(976 * x1 / 256) * x1 / 32768) + floor(7216 * x1 / 32768) + 113;
        else if (x1 > -1024 && x1 <= -768)
                y = floor(floor(442 * x1 / 256) * x1 / 32768) + floor(4060 * x1 / 32768) + 76;

        else if (x1 > -1280 && x1 <= -1024)
                y = floor(floor(177 * x1 / 256) * x1 / 32768) + floor(1956 * x1 / 32768) + 44;

        else if (x1 > 1280 && x1 < 1380)
                y = 254;
        else if (x1 >= 1380 && x1 < 1536)
                y = 255;
        else if (x1 >= 1536)
                y = 256;

        else if (x1 < 512 && x1 >= 256)
                y = floor(floor(-1530 * x1 / 256) * x1 / 32768) + floor(9490 * x1 / 32768) + 125;
        else if (x1 < 768 && x1 >= 512)
                y = floor(floor(-976 * x1 / 256) * x1 / 32768) + floor(7216 * x1 / 32768) + 143;
        else if (x1 < 1024 && x1 >= 768)
                y = floor(floor(-442 * x1 / 256) * x1 / 32768) + floor(4060 * x1 / 32768) + 180;
        else if (x1 <= 1280 && x1 >= 1024)
                y = floor(floor(-177 * x1 / 256) * x1 / 32768) + floor(1956 * x1 / 32768) + 212;

        else if (x1 <= -1280 && x1 > -1385)
                y = 2;
        else if (x1 < -1380 && x1 > -1536)
                y = 1;
        else if (x1 <= -1536)
                y = 0;
        return y;
}

// double sigmoid(double x)
// {
//         if (x > 500)
//                 x = 500;
//         if (x < -500)
//                 x = -500;
//         return 1 / (1 + exp(-x));
// }

/* ************************************************************ */
/* Forward Pass */
void forward_pass(unsigned char img[][32])
{

        // Convolution Operation + Sigmoid Activation
        for (int filter_dim = 0; filter_dim < 5; filter_dim++)
        {
                for (int i = 0; i < 28; i++)
                {
                        for (int j = 0; j < 28; j++)
                        {
                                max_pooling[filter_dim][i][j] = 0;

                                conv_layer[filter_dim][i][j] = 0;
                                sig_layer[filter_dim][i][j] = 0;
                                for (int k = 0; k < filter_size; k++)
                                {
                                        for (int l = 0; l < filter_size; l++)
                                        {
                                                // Q8.0 * Q7.8
                                                conv_layer[filter_dim][i][j] += (int)img[i + k + 1][j + l - 2] * conv_w_fp[filter_dim][k][l];
                                                // Option 1(wrong): truncate immediatley
                                                // conv_layer_fp[filter_dim][i][j] = conv_layer[filter_dim][i][j];
                                        }
                                }
                                // Option 2(wrong): truncate after accumulation
                                // conv_layer_fp[filter_dim][i][j] = conv_layer[filter_dim][i][j];

                                // Option 3: keep all bits
                                // sig_layer_fp[filter_dim][i][j] = sigmoid_test(conv_layer[filter_dim][i][j] + conv_b_fp[filter_dim][i][j]);

                                // Option 4: set to maximum
                                conv_layer[filter_dim][i][j] += conv_b_fp[filter_dim][i][j];
                                if (conv_layer[filter_dim][i][j] >= 32768)
                                        conv_layer_fp[filter_dim][i][j] = 32767;
                                else if (conv_layer[filter_dim][i][j] < -32768)
                                        conv_layer_fp[filter_dim][i][j] = -32768;
                                else
                                        conv_layer_fp[filter_dim][i][j] = conv_layer[filter_dim][i][j];

                                sig_layer_fp[filter_dim][i][j] = sigmoid_test(conv_layer_fp[filter_dim][i][j]);
                        }
                }
        }

        // MAX Pooling (max_pooling, max_layer)
        int cur_max = 0;
        int max_i = 0, max_j = 0;
        for (int filter_dim = 0; filter_dim < 5; filter_dim++)
        {
                for (int i = 0; i < 28; i += 2)
                {
                        for (int j = 0; j < 28; j += 2)
                        {
                                max_i = i;
                                max_j = j;
                                cur_max = sig_layer_fp[filter_dim][i][j];
                                for (int k = 0; k < 2; k++)
                                {
                                        for (int l = 0; l < 2; l++)
                                        {
                                                if (sig_layer_fp[filter_dim][i + k][j + l] > cur_max)
                                                {
                                                        max_i = i + k;
                                                        max_j = j + l;
                                                        cur_max = sig_layer_fp[filter_dim][max_i][max_j];
                                                }
                                        }
                                }
                                max_pooling[filter_dim][max_i][max_j] = 1;
                                max_layer_fp[filter_dim][i / 2][j / 2] = cur_max;
                        }
                }
        }

        int k = 0;
        for (int filter_dim = 0; filter_dim < 5; filter_dim++)
        {
                for (int i = 0; i < 14; i++)
                {
                        for (int j = 0; j < 14; j++)
                        {
                                dense_input_fp[k] = max_layer_fp[filter_dim][i][j];
                                k++;
                        }
                }
        }

        // Dense Layer
        for (int i = 0; i < 120; i++)
        {
                dense_sum[i] = 0;
                dense_sigmoid[i] = 0;
                for (int j = 0; j < 980; j++)
                {
                        // Q7.8 * Q7.8
                        dense_sum[i] += (dense_w_fp[j][i] * dense_input_fp[j]) >> FRACBITS;
                        // Option 1(wrong): truncate immediatley
                        // dense_sum_fp[i] = dense_sum[i];
                }
                // Option 2: truncate after accumulation
                dense_sum_fp[i] = dense_sum[i];

                dense_sum_fp[i] += dense_b_fp[i];
                dense_sigmoid_fp[i] = sigmoid_test(dense_sum_fp[i]);
        }

        // Dense Layer 2
        for (int i = 0; i < 10; i++)
        {
                dense_sum2[i] = 0;
                for (int j = 0; j < 120; j++)
                {
                        // Q7.8 * Q7.8
                        dense_sum2[i] += (dense_w2_fp[j][i] * dense_sigmoid_fp[j]) >> FRACBITS;
                        // Option 1: truncate immediatley
                        // dense_sum2_fp[i] = dense_sum2[i];
                }
                // Option 2: truncate after accumulation
                dense_sum2_fp[i] = dense_sum2[i];

                dense_sum2_fp[i] += dense_b2_fp[i];
        }

        // // Softmax Output
        // double den = softmax_den(dense_sum2, 10);
        // for (int i = 0; i < 10; i++)
        // {
        //         dense_softmax[i] = exp(dense_sum2[i]) / den;
        // }
}

void read_weights()
{
        std::ifstream fin("weights.txt");
        if (!fin)
        {
                std::cerr << "Unable to open weights!";
                exit(1);
        }

        for (int i = 0; i < 120; i++)
        {
                fin >> dense_b[i];
                dense_b_fp[i] = dense_b[i] * pow(2, FRACBITS);
        }

        for (int j = 0; j < 10; j++)
        {
                fin >> dense_b2[j];
                dense_b2_fp[j] = dense_b2[j] * pow(2, FRACBITS);
        }

        for (int i = 0; i < 120; i++)
                for (int j = 0; j < 10; j++)
                {
                        fin >> dense_w2[i][j];
                        dense_w2_fp[i][j] = dense_w2[i][j] * pow(2, FRACBITS);
                }

        for (int k = 0; k < 980; k++)
                for (int i = 0; i < 120; i++)
                {
                        fin >> dense_w[k][i];
                        dense_w_fp[k][i] = dense_w[k][i] * pow(2, FRACBITS);
                }

        for (int i = 0; i < 5; i++)
                for (int k = 0; k < 7; k++)
                        for (int j = 0; j < 7; j++)
                        {
                                fin >> conv_w[i][k][j];
                                if (int(conv_w[i][k][j] * pow(2, FRACBITS) >= 32768))
                                        conv_w_fp[i][k][j] = 32767;
                                else if (int(conv_w[i][k][j] * pow(2, FRACBITS) < -32768))
                                        conv_w_fp[i][k][j] = -32768;
                                else
                                conv_w_fp[i][k][j] = conv_w[i][k][j] * pow(2, FRACBITS);
                        }

        for (int i = 0; i < 5; i++)
                for (int l = 0; l < 28; l++)
                        for (int m = 0; m < 28; m++)
                        {
                                fin >> conv_b[i][l][m];
                                conv_b_fp[i][l][m] = conv_b[i][l][m] * pow(2, FRACBITS);
                        }
}

void read_test_data()
{
        std::ifstream csvread;
        csvread.open("/cad2/ece1718s/mnist_test.csv", std::ios::in);
        if (csvread)
        {
                std::string s;
                int data_pt = 0;
                while (getline(csvread, s))
                {
                        std::stringstream ss(s);
                        int pxl = 0;
                        while (ss.good())
                        {
                                std::string substr;
                                getline(ss, substr, ',');
                                if (pxl == 0)
                                {
                                        label_test[data_pt] = stoi(substr);
                                }
                                else
                                {
                                        data_test[data_pt][pxl - 1] = stoi(substr);
                                }
                                pxl++;
                        }
                        data_pt++;
                }
                csvread.close();
        }
        else
        {
                std::cerr << "Unable to read test data!" << std::endl;
                exit(EXIT_FAILURE);
        }
}

void give_img(unsigned char *vec, unsigned char img[][32])
{
        int k = 0;
        for (int i = 0; i < 35; i++)
        {
                for (int j = 0; j < 32; j++)
                {
                        if (i < 5 || j < 2 || i > 32 || j > 29)
                        {
                                img[i][j] = 0;
                        }
                        else
                        {
                                img[i][j] = vec[k++];
                        }
                }
        }
}

int give_prediction_test()
{
        int max_val = dense_sum2_fp[0];
        int max_pos = 0;
        for (int i = 1; i < 10; i++)
        {
                if (dense_sum2_fp[i] > max_val)
                {
                        max_val = dense_sum2_fp[i];
                        max_pos = i;
                }
        }

        return max_pos;
}

int main()
{
        read_test_data();
        read_weights();
        int val_len = 600;
        int cor = 0;
        int confusion_mat[10][10];
        for (int i = 0; i < 10; i++)
        {
                for (int j = 0; j < 10; j++)
                        confusion_mat[i][j] = 0;
        }

        std::cout << "Start Testing." << std::endl;
        for (int i = 0; i < val_len; i++)
        {
                unsigned char img[35][32];
                give_img(data_test[i], img);
                forward_pass(img);
                int pre = give_prediction_test();
                confusion_mat[label_test[i]][pre]++;
                if (pre == label_test[i])
                        cor++;
        }
        float accu = double(cor) / val_len;
        std::cout << "Accuracy: " << accu << std::endl;

        std::cout << "   0 1 2 3 4 5 6 7 8 9" << std::endl;
        for (int i = 0; i < 10; i++)
        {
                std::cout << i << ": ";
                for (int j = 0; j < 10; j++)
                {
                        std::cout << confusion_mat[i][j] << " ";
                }
                std::cout << std::endl;
        }

        cor = 0;
        for (int i = 0; i < 10; i++)
        {
                for (int j = 0; j < 10; j++)
                        confusion_mat[i][j] = 0;
        }

        std::ifstream fin("../verification_files/forward_pass_top/res.txt");
        if (!fin)
        {
                std::cerr << "Unable to open results!";
                exit(1);
        }
        std::cout << "Testing hardware results." << std::endl;
        int res[10] = {};
        char sign = 1;
        char bit;
        for (int i = 0; i < val_len; i++)
        {
                for (int num = 9; num >= 0; num--) // result vector is in the order of 9 to 0, each 16 bits
                {
                        res[num] = 0;
                        fin >> bit;
                        sign = 1;
                        if (bit == '1')
                                sign = -1;

                        for (int w = 14; w >= 0; w--)
                        {
                                fin >> bit;
                                res[num] += pow(2, w) * (bit - '0');
                        }
                        if (sign == -1)
                        {
                                res[num] -= 32768; // according to 2's complement
                        }
                }

                int max_val = res[0];
                int max_pos = 0;
                for (int i = 1; i < 10; i++)
                {
                        if (res[i] > max_val)
                        {
                                max_val = res[i];
                                max_pos = i;
                        }
                }

                int pre = max_pos;
                confusion_mat[label_test[i]][pre]++;
                if (pre == label_test[i])
                        cor++;
        }

        accu = double(cor) / val_len;
        std::cout << "Accuracy: " << accu << std::endl;

        std::cout << "   0 1 2 3 4 5 6 7 8 9" << std::endl;
        for (int i = 0; i < 10; i++)
        {
                std::cout << i << ": ";
                for (int j = 0; j < 10; j++)
                {
                        std::cout << confusion_mat[i][j] << " ";
                }
                std::cout << std::endl;
        }
        return 0;
}
