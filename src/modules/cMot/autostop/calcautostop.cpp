#include <bits/stdc++.h>
using namespace std;
int main(int argc,char *argv[]){
    double v;

	if(argc==2){
		v=stod(argv[1]);
	}else{
		cin>>v;
	}
    // double a=-1.0/500.0;
    // double b=250.0*-2.0*a;
    // auto f=[&](double x)->double{
    //     return a*x*x+b*x+0;
    // };
    // // cout<<v<<' '<<a*v*v<<' '<<b*v<<endl;
    // printf("%d",(int)f(v));
    
    printf("%d",(int)(126*(v/250.0)));

    return 0;
}