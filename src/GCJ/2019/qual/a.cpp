#include <iostream>
#include <string>
using namespace std;
#define REP(i, n) for(int i = 0; i < (int)(n); i++)
#define RREP(i, n) for(int i = (int)(n)-1; i >= 0; i--)
#define ALL(v) (v).begin(), (v).end()
using ll = long long int;

int T;
string N, A, B;
int as[110];
int bs[110];
int main() {
  cin >> T;
  REP(i, T) {
    cin >> N;
    ll s = N.size();
    REP(j, s) {
      int x = N[j] - '0';
      if (x == 4) {
        as[j] = 2;
        bs[j] = 2;
      } else {
        as[j] = 0;
        bs[j] = x;
      }
    }
    A = "";
    B = "";
    REP(j, s) {
      if (as[j] != 0 || !A.empty()) {
        A += to_string(as[j]);
      }
      if (bs[j] != 0 || !B.empty()) {
        B += to_string(bs[j]);
      }
    }
    if (A.empty()) {
      A = "0";
    }
    if (B.empty()) {
      B = "0";
    }
    cout << "Case #" << (i+1) << ": " << A << " " << B << endl;
  }
  return 0;
}
