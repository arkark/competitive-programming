#include <iostream>
#include <string>
using namespace std;
#define REP(i, n) for(int i = 0; i < (int)(n); i++)
#define RREP(i, n) for(int i = (int)(n)-1; i >= 0; i--)
#define ALL(v) (v).begin(), (v).end()
using ll = long long int;

int T;
ll N;
string P, Q;
int main() {
  cin >> T;
  REP(i, T) {
    cin >> N >> P;
    Q = "";
    int s = P.size();
    REP(i, s) {
      Q += (P[i] == 'E' ? "S" : "E");
    }
    cout << "Case #" << (i+1) << ": " << Q << endl;
  }
  return 0;
}
