//%^~
#include <bits/stdc++.h>
#define INF 0x7fffffff
#define MAXN 100005
#define eps 1e-9
#define foru(a,b,c)	for(int a=b;a<=c;a++)
#define RT return 0;
#define LL long long
#define LXF int
#define RIN rin()
#define HH printf("\n")
#define All(x) (x).begin(),(x).end()
#define fi first
#define se second
using namespace std;
inline LXF rin(){
	LXF x=0,w=1;
	char ch=0;
	while(ch<'0'||ch>'9'){ 
	if(ch=='-') w=-1;
	ch=getchar();
	}
	while(ch>='0'&&ch<='9'){
	x=x*10+(ch-'0');
	ch=getchar();
	}
	return x*w;
}
signed main(){
//	freopen("CSRMTickerFast.cfg","w",stdout);
	foru(i,1,20){
//		freopen("CSRMTickerFast.cfg","a",stdout);
//		foru(j,1,1){
//			cout<<("exec_async CSRM/Ticker/CSRMTickerFast"+to_string(i))<<endl;
//		}
//		cout<<endl;
		freopen(("CSRMTickerFast"+to_string(i)+".cfg").c_str(),"w",stdout);
		string s="ct7"+to_string(i);
		s="%";
		foru(j,1,i-1){
			cout<<"sleep 775000\n";
		}
//		cout<<(s+"_begin")<<'\n';
		string out[2]={s+"\n","sleep 9\n"};
		for(int j=1;j<=155001;j++){
			if(i==1 && j==2){
				cout<<"alias ldfst ;";
			}
			cout<<out[j&1];
//			cout<<"%\n";
		}
//		cout<<("echo done "+s);
	}
	return 0;
}
