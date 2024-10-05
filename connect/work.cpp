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
	freopen("Preference_raw.cfg","r",stdin);
	freopen("work.json","w",stdout);
	foru(i,1,37){
		string a,b,c;
		cin>>a>>b>>c;
		string t;
		for(auto ch:c){
			if(ch=='"'){
				t+="\\\"";
			}else{
				t+=ch;
			}
		}
		printf("\"%s\" : {\n",t.c_str());
		printf("	\"key\" : \"%s\",\n",b.c_str());
		printf("	\"content\" : \"%s\",\n",t.c_str());
		printf("	\"ban\" : \"\",\n");
		printf("	\"ban-text\" : \"\"\n");
		printf("},\n");
	}
	return 0;
}
