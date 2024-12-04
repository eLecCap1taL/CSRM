#include <bits/stdc++.h>
#include <windows.h>
using namespace std;
double getdelay(int fps){
    int sleepframe=(9*fps+999)/1000;
    double frametime=1000.0/(double)fps;
    return sleepframe*frametime+frametime;
}
int main(int argc,char *argv[]){
    int fps;

	if(argc==2){
		fps=stoi(argv[1]);
	}else{
		cin>>fps;
	}

    //calc ticker duration
    double dur=getdelay(fps);

    //first tick's expected delay is half the duration
    // double expdur=dur*0.5;

    //simulated
    double tot=0;
    int lstcnt=-1;
    for(int idx=0;idx<=1000;idx++){
        system(format("echo {:.2f} > file1",tot).c_str());
        system(format("calcspeed --cubic < file1 > file2").c_str());
        
        freopen("file2","r",stdin);
        cin.clear();
        double curspd=-1;
        cin>>curspd;

        system(format("calcautostop < file2 > file3").c_str());

        freopen("file3","r",stdin);
        cin.clear();
        double jttime=-1;
        cin>>jttime;
/*



*/
        double add=dur*0.7;
        double maxjt=126;
        double a=add/(maxjt*maxjt-maxjt*2*maxjt);
        double b=maxjt*-2.0*a;
        double dx=0.48;
        auto f=[&](double x)->double{
            // return a*x*x+b*x+0;
            return ((add-dx*add)/(maxjt*maxjt))*(x*x)+dx*add;
            // return add*(x/maxjt);
            // return add;
        };
        jttime+=f(jttime);
        // cout<<jttime<<" add "<<f(jttime)<<endl;


        int jtcnt=0;
        double res=0;
        while(1){
            if(res==0){
                if(res+dur*0.5<=jttime){
                    res+=dur*0.5;
                    jtcnt++;
                    continue;
                }else{
                    // cout<<"fail: "<<jttime-(res+expdur)<<endl;
                }
            }else{
                if(res+dur<=jttime){
                    res+=dur;
                    jtcnt++;
                    continue;
                }else{
                    // cout<<"fail: "<<jttime-(res+dur)<<endl;
                }
            }
            break;
        }
        if(jtcnt!=lstcnt){
            cout<<idx<<' '<<jtcnt<<' '<<curspd<<' '<<jttime<<endl;
            lstcnt=jtcnt;
        }

        if(tot==0){
            tot+=dur*0.75;
        }else{
            tot+=dur;
        }

        if(curspd==250){
            break;
        }
    }

    return 0;
}