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
	string reg;
	printf("请先为你的道具指定一个英文名(数字或英文字母):");
	cin>>reg;
	HH;
	
	printf("游戏内站到你的道具位置,瞄好点,控制台输入getpos");
	HH;
	
	double x;
	double y;
	printf("输入setang后第一个数(完整的小数,不要只输入小数点前):");
	cin>>y;
	HH; 
	printf("输入setang后第二个数(完整的小数,不要只输入小数点前):");
	cin>>x;
	HH;
	printf("输入1代表站立、输入2代表需要下蹲:");
	int b=RIN;
	HH;
	printf("输入1代表直接投、输入2代表跳投、输入3代表前跳投:");
	int a=RIN;
	printf("输入1代表烟雾、输入2代表闪光、输入3代表燃烧弹、输入4代表手雷、输入5代表诱饵弹:");
	int c=RIN;
	HH;
	string ls;
	if(c==1){
		ls="SetItemSmoke";
	}else if(c==2){
		ls="SetItemFlash";
	}else if(c==3){
		ls="SetItemMolo";
	}else if(c==4){
		ls="SetItemGrenade";
	}else if(c==5){
		ls="SetItemDecoy";
	}
	x/=-0.05544;
	y/=0.05544;
	freopen("./CustomGrenade/CustomGrenadeRegedit.cfg","a+",stdout);
	string ch="1";
	ch[0]='"';
	HH;
	cout<<("alias "+reg+" "+ch+"yaw ")<<x<<" 1 1;pitch "<<y<<" 1 1;"<<(a==1?"SetT":(a==2?"SetJP":"SetFJP"))<<";"<<(b==1?"SetNone":"SetDuck ")<<";"<<ls<<";SetPreAimOff"<<ch;
	return 0;
}
