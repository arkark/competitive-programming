#include<iostream>
#include<vector>
#define REP(i, n) for(int i=0; (i)<(n); (i)++)
using ll = long long int;
using namespace std;

vector<ll> as = {4, 1, 4, 1, 4};
ll f(ll d, ll c, ll N) {
  if (d == as.size()) {
    return c <= N;
  } else {
    ll res = 0;
    REP(i, as[d]+1) {
      res += f(d+1, c+i, N);
    }
    return res;
  }
}

int main() {
  ll N;
  cin >> N;
  ll ans = f(0, 0, N);
  cout << ans << endl;
}
