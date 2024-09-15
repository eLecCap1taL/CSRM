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
	freopen("8DirectionAutoStop.cfg","r",stdin);
	string s;
	while(getline(cin,s)){
		cout<<s<<endl;
	}
	return 0;
}
