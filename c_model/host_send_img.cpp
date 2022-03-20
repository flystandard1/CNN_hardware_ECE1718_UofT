#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
using namespace std;

unsigned char data_test[10000][784];
unsigned char label_test[10000];

void read_test_data()
{
    ifstream csvread;
    csvread.open("/cad2/ece1718s/mnist_test.csv", ios::in);
    if (csvread)
    {
        string s;
        int data_pt = 0;
        while (getline(csvread, s))
        {
            stringstream ss(s);
            int pxl = 0;
            while (ss.good())
            {
                string substr;
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
        cerr << "Unable to read test data!" << endl;
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

int main()
{
    read_test_data();

    std::ofstream fout("img_in_bus.txt");
    int val_len = 600;
    for (int i = 0; i < val_len; i++)
    {
        unsigned char img[35][32];
        give_img(data_test[i], img);
        for (int j = 0; j < 35; j++)
            for (int k = 0; k < 32; k++)
            {
                if (k % 8 == 0 && !(k == 0 && j == 0 && i == 0))
                    fout << endl;
                fout << std::hex << setw(2) << setfill('0') << int(img[j][7 - k + k / 8 * 16]);
            }
    }

    return 0;
}
