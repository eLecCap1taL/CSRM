//%^~
#include <bits/stdc++.h>
#define INF 0x7fffffff
#define MAXN 100005
#define eps 1e-9
#define foru(a, b, c) for (int a = b; a <= c; a++)
#define RT return 0;
#define LL long long
#define LXF int
#define RIN rin()
#define HH printf("\n")
#define All(x) (x).begin(), (x).end()
#define fi first
#define se second
using namespace std;
inline LXF rin()
{
    LXF x = 0, w = 1;
    char ch = 0;
    while (ch < '0' || ch > '9') {
        if (ch == '-')
            w = -1;
        ch = getchar();
    }
    while (ch >= '0' && ch <= '9') {
        x = x * 10 + (ch - '0');
        ch = getchar();
    }
    return x * w;
}
signed main()
{
	freopen("data.txt","r",stdin);
	string s;
	freopen("load.cfg","w",stdout);
	while(cin>>s){
		freopen("load.cfg","a",stdout);
		cout<<"exec CSRM/Addon/Practice/hintMenu/spawn/";
		cout<<s<<endl;
		freopen((s+".cfg").c_str(),"w",stdout);
		int ct=RIN,t=RIN;
		bool rdpos=RIN;
		vector<string> ls(ct+t+1,"");
		if(rdpos){
			foru(i,1,ct+t){
				getline(cin,ls[i]);
			}
		}
		string ds=s;
		ds[0]+='A'-'a';
		//gen
		printf("alias csrmPracticeS%sBack \"+csrmPracticeMap;+csrmHintMenu\"\n",ds.c_str());
		printf("alias +csrmPracticeS%s \"alias csrmHintMenu_viewPrefByMenu csrmPS%sView_CT1;alias csrmHintMenu_viewLastWhichMenu csrmHintMenu_viewLastByS%s;alias csrmHintMenu_backByMenu csrmPracticeS%sBack\"\n",ds.c_str(),ds.c_str(),ds.c_str(),ds.c_str());
		printf("alias -csrmPracticeS%s \"\"\n",ds.c_str());
		HH;
		HH;
		vector<string> cyc;
		cyc.push_back("");
		foru(i,1,ct){
			cyc.push_back(("CT"+to_string(i)));
		}
		foru(i,1,t){
			cyc.push_back(("T"+to_string(i)));
		}
		cyc[0]=cyc.back();
		cyc.push_back(cyc[0]);
		foru(i,1,ct+t){
			printf("alias csrmPS%sView_%s \"csrmHint_show_spawn_%s;alias csrmHintMenu_pickByMenu csrmPS%sPick_%s;alias csrmHintMenu_preByMenu csrmPS%sView_%s;alias csrmHintMenu_nxtByMenu csrmPS%sView_%s;csrmHintMenu_isPicking\"\n",
					ds.c_str(),cyc[i].c_str(),cyc[i].c_str(),ds.c_str(),cyc[i].c_str(),ds.c_str(),cyc[i-1].c_str(),ds.c_str(),cyc[i+1].c_str());
		}
		HH;
		HH;
		foru(i,1,ct+t){
			printf("alias csrmPS%sPick_%s \"%s;alias csrmHintMenu_viewLastByS%s csrmPS%sView_%s\"\n",
					ds.c_str(),cyc[i].c_str(),ls[i].c_str(),ds.c_str(),ds.c_str(),cyc[i].c_str());
		
		}
	}
    return 0;
}
