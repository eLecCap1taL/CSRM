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
	freopen("Random.cfg","w",stdout);
	int n=100,m=3;
	vector<vector<int>> to(n+1,vector<int>(3,0));
	
	srand(time(0));
	foru(i,1,n){
		rd.push_back(i);
	}
	
	foru(j,0,m-1){
		random_shuffle(All(rd));
		foru(i,1,n){
			to[i][j]=rd[i-1];
		}
	}
	
	string Base="CSRM_Random_";
	string edge="edge";
	printf("alias CSRM_Random_Num \"CSRM_Random_Status;CSRM_Random_edge0\"\n\n\n");
	foru(i,1,n){
		printf("alias %s \"alias %s %s;",(Base+to_string(i)).c_str(),(Base+"Status").c_str(),(Base+to_string(i)+"_content").c_str());
		foru(j,0,m-1){
			printf("alias %s %s;",(Base+edge+to_string(j)).c_str(),(Base+to_string(to[i][j])).c_str()); 
		}
		printf("\"\n");
	}
	HH;HH;
	printf("alias CSRM_Random_On \"alias CSRM_Random_MouseX CSRM_Random_edge0;alias CSRM_Random_MouseY CSRM_Random_edge1;alias CSRM_Ticker_Random CSRM_Random_edge2\"\n");
	printf("alias CSRM_Random_Off \"alias CSRM_Random_MouseX ;alias CSRM_Random_MouseY ;alias CSRM_Ticker_Random \"\n");
	printf("CSRM_Random_1\n");
	printf("CSRM_Random_Off\n");
	HH;HH;
	foru(i,1,n){
		printf("alias %s \"%s\"\n",(Base+to_string(i)+"_content").c_str(),("say "+to_string(i)).c_str());
	}
	return 0;
}
