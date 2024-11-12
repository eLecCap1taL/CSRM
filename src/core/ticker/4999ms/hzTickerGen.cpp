#include <bits/stdc++.h>
using namespace std;
int main(){
    int dur=4999;
    int n=120000;
    int m=5;
    string idx="c";
    string midx="4999ms";
    
    if(!filesystem::exists("files")){
        filesystem::create_directories("files");
    }

    string ot[2];
    ot[0]=format("sleep {}",dur);
    

    for(int i=1;i<=m;i++){
        auto getid=[&]()->char{
            int x=i-1;
            char C='0';
            if(x>=10)   C='a',x-=10;
            return C+x;
        };
        ofstream fout(format("files/_{}.cfg",getid()),ios::out);
        // cout<<getid()<<endl;
        ot[1]=format("%{}{}",idx,getid());
        for(int j=1;j<i;j++){
            fout<<format("sleep {}\n",n/2*dur);
        }
        fout<<format("hzTicker_{}_{}_bg\n",idx,getid());
        for(int j=1;j<=n;j++){
            fout<<ot[j & 1]<<'\n';
        }
        if(i==m){
            fout<<format("exec Horizon/src/core/ticker/{}/dead",midx);
        }
        fout.close();
    }
    ofstream fout(format("dead.cfg",idx),ios::out);
    fout<<format("//will last {:.4f}s ({:.4f}h)\n",(n/2)/1000.0*dur*m,double((n/2)*dur/1000.0/3600.0*m));
    fout<<format("alias %{0} \"say_team Ticker {0} died!\"",idx);
    fout.close();
    
    // fout=ofstream(format("register.cfg",idx),ios::out);

    fout=ofstream(format("init.cfg",idx),ios::out);
    fout<<format("alias hzTicker_{}_clr \"",idx);
    for(int i=1;i<=m;i++){
        auto getid=[&]()->char{
            int x=i-1;
            char C='0';
            if(x>=10)   C='a',x-=10;
            return C+x;
        };
        fout<<format("alias %{}{} {}",idx,getid(),(i==m?"":";"));
    }
    fout<<"\"\n";
    fout<<endl;
    for(int i=1;i<=m;i++){
        auto getid=[&]()->char{
            int x=i-1;
            char C='0';
            if(x>=10)   C='a',x-=10;
            return C+x;
        };
        fout<<format("alias hzTicker_{0}_{1}_bg \"hzTicker_{0}_clr;alias %{0}{1} %{0}\"\n",idx,getid());
    }
    fout<<endl;
    fout<<format("exec Horizon/src/core/ticker/{}/reg",midx)<<endl;
    fout<<endl;
    for(int i=1;i<=m;i++){
        auto getid=[&]()->char{
            int x=i-1;
            char C='0';
            if(x>=10)   C='a',x-=10;
            return C+x;
        };
        fout<<format("exec_async Horizon/src/core/ticker/{}/files/_{}.cfg\n",midx,getid());
    }

    return 0;
}