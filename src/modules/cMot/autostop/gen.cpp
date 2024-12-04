#include <bits/stdc++.h>
using namespace std;
vector<int> fps;
void readFPS(){
    ifstream fin("genlist.txt",ios::in);
    int x;
    while(fin>>x){
        fps.push_back(x);
    }
}
vector<pair<int,int>> ls;
void gen(int v,int idx,string f1,string s1,string s2){
    int N=40;

    ofstream fout(format("list/{}/{}_{}.cfg",f1,idx,v));

    int j;
    
    j=0;
    for(int i=0;i<=N;i++){
        while(j<ls.size() && ls[j].first<i) j++;
        string ot="";
        if(ls[j].first==i){
            ot=format("alias cMot_autostop_{}_reltarget cMot_autostop_{}_work{}",s1,s1,ls[j].second);
        }    
        fout<<format("alias cMot_autostop_{}_beat{}_tsk \"{}\"\n",s1,i,ot);
    }
    fout<<endl;
    j=0;
    for(int i=0;i<=N;i++){
        while(j<ls.size() && ls[j].first<i) j++;
        string ot="";
        if(ls[j].first==i){
            ot=format("alias cMot_autostop_{}_reltarget cMot_autostop_{}_work{}",s2,s2,ls[j].second);
        }    
        fout<<format("alias cMot_autostop_{}_beat{}_tsk \"{}\"\n",s2,i,ot);
    }
    fout<<endl;

    cout<<format("gen<{},{},{},{}> completed\n",v,f1,s1,s2);
}
int main(){
    readFPS();
    int idx=0;
    ofstream fout("list/init.cfg",ios::out);
    for(auto FPS:fps){
        cout<<format("\nwork with fps={}\n",FPS);
        system(format("calc {} > dat.txt",FPS).c_str());

        ls.clear();
        ifstream fin("dat.txt",ios::in);
        int x,y;
        double tmp;
        while(fin>>x){
            fin>>y;
            fin>>tmp;
            fin>>tmp;
            ls.push_back({x,y});
            cout<<x<<' '<<y<<endl;
        }
        for(int i=0;i<ls.size();i++){
            if(ls[i].second==1){
                ls[i].first=ls[i+1].first-1;
            }
        }
        idx++;
        cout<<format("dat gen completed\n",FPS);
        gen(FPS,idx,"RL","r","l");
        gen(FPS,idx,"FB","f","b");

        fout<<format("alias cMot_autostopmode_{} \"exec Horizon/src/modules/cMot/FB/policy/{}_{};exec Horizon/src/modules/cMot/RL/policy/{}_{}\"\n",idx,idx,FPS,idx,FPS);
    }
    return 0;
}