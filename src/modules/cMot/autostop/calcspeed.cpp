#include <bits/stdc++.h>
#define fi first
#define se second
#define foru(a,b,c) for(int a=(b);a<=(c);a++)
using namespace std;
pair<double,double> a[1000]={
{0.00,0.00},
{1.00,4.51},
{2.00,5.26},
{3.00,5.90},
{4.00,6.44},
{5.00,8.55},
{6.00,10.13},
{7.00,11.71},
{8.00,12.24},
{9.00,14.87},
{10.00,16.51},
{11.00,17.63},
{12.00,19.38},
{13.00,21.26},
{15.00,23.95},
{17.00,27.69},
{19.00,30.85},
{22.00,35.64},
{25.00,40.50},
{28.00,45.23},
{32.00,51.66},
{35.00,55.93},
{38.00,60.67},
{41.00,65.99},
{44.00,70.67},
{47.00,75.29},
{51.00,81.95},
{53.00,85.14},
{57.00,91.47},
{60.00,96.28},
{63.00,100.60},
{67.00,106.48},
{70.00,110.62},
{78.00,121.43},
{85.00,130.30},
{95.00,141.48},
{105.00,152.44},
{115.00,162.00},
{125.00,170.95},
{135.00,179.09},
{151.00,190.46},
{167.00,200.43},
{187.00,211.00},
{208.00,220.17},
{221.00,225.17},
{236.00,230.16},
{250.00,234.12},
{265.00,238.05},
{276.00,240.55},
{280.00,241.24},
{290.00,243.36},
{300.00,245.13},
{320.00,248.36},
{340.00,250.00}
};
string HelpText=R"(
Usage:

First argument: Interpolation algorithm
  --liner		Linear interpolation
  --cubic		Cubic interpolation

Third argument: Calculation time
  number       The time point to calculate

Example:
  calcSpeed.exe --liner 20
    Calculate the speed at 20 milliseconds using linear interpolation.

  calcSpeed.exe --cubic 300
    Calculate the speed at 300 milliseconds using Cubic interpolation.
)";
void showhelp(){
	cout<<HelpText<<endl;
	exit(0);
}
class CubicSpline {
public:
    CubicSpline(const vector<double>& x, const vector<double>& y) {
        n = x.size();
        this->x = x;
        this->y = y;
        a.resize(n);
        b.resize(n - 1);
        c.resize(n);
        d.resize(n - 1);
        calculateCoefficients();
    }

    double interpolate(double x_value) {
        int i = findInterval(x_value);
        double dx = x_value - x[i];
        return a[i] + b[i] * dx + c[i] * dx * dx + d[i] * dx * dx * dx;
    }

private:
    int n;
    vector<double> x, y;
    vector<double> a, b, c, d;

    void calculateCoefficients() {
        vector<double> h(n-1), alpha(n-1), l(n), mu(n-1), z(n);

        for (int i = 0; i < n - 1; ++i) {
            h[i] = x[i+1] - x[i];
            if (h[i] == 0) {
                exit(1);
            }
            if (i > 0) {
                alpha[i] = (3.0 / h[i]) * (y[i+1] - y[i]) - (3.0 / h[i-1]) * (y[i] - y[i-1]);
            }
        }

        l[0] = 1.0;
        mu[0] = 0.0;
        z[0] = 0.0;

        for (int i = 1; i < n - 1; ++i) {
            l[i] = 2.0 * (x[i+1] - x[i-1]) - h[i-1] * mu[i-1];
            mu[i] = h[i] / l[i];
            z[i] = (alpha[i] - h[i-1] * z[i-1]) / l[i];
        }

        l[n-1] = 1.0;
        z[n-1] = 0.0;
        c[n-1] = 0.0;
		
        for (int j = n-2; j >= 0; --j) {
            c[j] = z[j] - mu[j] * c[j+1];
            b[j] = (y[j+1] - y[j]) / h[j] - h[j] * (c[j+1] + 2.0 * c[j]) / 3.0;
            d[j] = (c[j+1] - c[j]) / (3.0 * h[j]);
            a[j] = y[j];
        }
    }

    int findInterval(double x_value) {
        int i = 0;
        while (i < n-1 && x_value > x[i+1]) {
            ++i;
        }
        return i;
    }
};
int main(int argc, char *argv[]){
	// foru(i,1,54){
		// double x,y;
		// cin>>x>>y;
		// printf("{%.2lf,%.2lf},\n",x,y);
	// }
	int N=53;
	
	vector<string> argls;
	for(int i=1;i<argc;i++){
		argls.push_back(string(argv[i]));
	}

	if(argls.size()!=2 && argls.size()!=1){
		showhelp();
	}

	bool A=1;
	double t=0;
	
	if(argls[0]=="--liner"){
		A=0;
	}else if(argls[0]=="--cubic"){
		A=1;
	}else{
		showhelp();
	}

	if(argls.size()==2){
		for(auto c:argls[1]){
			if(c<'0' || c>'9')	showhelp();
		}
		t=atoi(argls[1].c_str());
	}else{
		cin>>t;
	}

	// cout<<A<<' '<<B<<' '<<t<<endl;

	sort(a,a+1+N);

	foru(i,0,N){
		a[i].fi*=100.0/60.0;
	}

	if(t>=a[N].fi){
		cout<<a[N].se<<endl;
		exit(0);
	}

	pair<double,double> lf,rf;
	for(int i=0;i<N;i++){
		if(t>=a[i].fi && t<a[i+1].fi){
			lf=a[i],rf=a[i+1];
			break;
		}
	}

	if(A==0){
		double ans=rf.se-lf.se;
		double dur=rf.fi-lf.fi;
		double res=t-lf.fi;
		ans*=res/dur;
		ans+=lf.se;
		printf("%.2lf",ans);
		exit(0);
	}else{
		double ans=0;
		
		vector<double> x,y;
		foru(i,0,N){
			x.push_back(a[i].fi);
			y.push_back(a[i].se);
		}
		CubicSpline inp(x,y);

		printf("%.2lf",inp.interpolate(t));
		exit(0);
	}

	
	return 0;
}