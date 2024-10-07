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
vector<int> rd;
signed main(){
	freopen("Scaler.cfg","w",stdout);
	int n=100,m=2;
	vector<vector<int>> to(n+1,vector<int>(3,0));
	
	srand(time(0));
	foru(i,1,n){
		rd.push_back(i);
	}
	
	foru(i,1,n){
		to[i][0]=i-3;
	}
	
	foru(i,1,n){
		to[i][1]=i+3;
	}
	
	string Base="CSRM_RadarScale_";
	string edge="edge";
//	printf("alias CSRM_Random_Num \"CSRM_Random_Status;CSRM_Random_edge0\"\n\n\n");
	foru(i,1,n){
		printf("alias %s \"cl_radar_scale %.2lf;",(Base+to_string(i)).c_str(),(double)i/(double)n);
		foru(j,0,m-1){
			string T=(Base+to_string(to[i][j]));
			if(to[i][j]<45 || to[i][j]>100)	T="";
			printf("alias %s %s;",(Base+edge+to_string(j)).c_str(),T.c_str()); 
		}
		printf("\"\n");
	}
	return 0;
}
