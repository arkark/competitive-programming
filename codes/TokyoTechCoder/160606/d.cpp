#include<cstdio>
#include<iostream>
#include<algorithm>
#include<cstring>
#include<string>
#include<complex>

using namespace std;

#define FOR(i,a,b) for (int i=(a);i<(b);i++)
#define RFOR(i,a,b) for (int i=(b)-1;i>=(a);i--)
#define REP(i,n) for (int i=0;i<(n);i++)
#define RREP(i,n) for (int i=(n)-1;i>=0;i--)
typedef long long ll;

ll N, M;
ll ary[200000];
ll solve() {
    scanf("%lld%lld", &N, &M);
    REP(i, N) ary[i]=0;
    ll p1, p2;
    REP(i, M) {
        p1 = p2;
        scanf("%lld", &p2);
        if (i==0) continue;
        ary[min(p1, p2)-1]++;
        ary[max(p1, p2)-1]--;
    }
    REP(i, N) {
        if (i==0) continue;
        ary[i] += ary[i-1];
    }

    ll ans = 0;
    REP(i, N-1) {
        ll a, b, c;
        scanf("%lld%lld%lld", &a, &b, &c);
        ans += min(a*ary[i], b*ary[i]+c);
    }
    return ans;
}

int main() {
    printf("%lld\n", solve());
    return 0;
}
