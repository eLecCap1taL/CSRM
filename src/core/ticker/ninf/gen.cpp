#include <bits/stdc++.h>
using namespace std;
int main(){
    int slp=515000;
    int N=22;
    ofstream init("init.cfg",ios::out);
    for(int i=1;i<=N;i++){
        init<<format("exec_async Horizon/src/core/ticker/ninf/file/_{}.cfg\n",i);
    }
    for(int o=1;o<=N;o++){
        ofstream fout(format("file/_{}.cfg",o),ios::out|ios::binary);
        for(int i=1;i<o;i++){
            fout<<format("sleep {}\n",slp);
        }
        for(int i=1;i<=520000;i++){
            fout<<"$"<<'\n';
        }
    }
    cout<<format("will last {:.5f}h",N*slp*1.0/1000.0/3600.0);
    return 0;
}