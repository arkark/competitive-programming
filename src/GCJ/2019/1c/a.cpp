#include <bits/stdc++.h>
using namespace std;
#define REP(i, n) for(int i = 0; i < (int)(n); i++)
#define RREP(i, n) for(int i = (int)(n)-1; i >= 0; i--)
#define ALL(v) (v).begin(), (v).end()
using ll = long long int;

vector<string> as = vector<string>(300);
vector<bool> bs = vector<bool>(300);

ll f(char c) {
  if (c == 'R') return 0;
  if (c == 'P') return 1;
  if (c == 'S') return 2;
  return -1;
}
char g(int bits) {
  if (bits>>0&1) return 'P';
  if (bits>>1&1) return 'S';
  if (bits>>2&1) return 'R';
  return 0;
}
char h(int bits) {
  if ((bits>>0&1) && (bits>>1&1)) return 'P';
  if ((bits>>1&1) && (bits>>2&1)) return 'S';
  if ((bits>>2&1) && (bits>>0&1)) return 'R';
  return 0;
}

int main() {
  ll T;
  cin >> T;
  REP(testIndex, T) {
    ll C;
    cin >> C;
    REP(i, C) {
      cin >> as[i];
      bs[i] = false;
    }
    string ans = "";
    bool ok = false;
    REP(j, 800) {
      int bits = 0;
      REP(i, C) {
        if (bs[i]) continue;
        bits |= 1<<f(as[i][j%as[i].size()]);
      }
      int cnt = bitset<32>(bits).count();
      if (cnt == 0) {
        ok = true;
        break;
      } else if (cnt == 1) {
        ans += g(bits);
        ok = true;
        break;
      } else if (cnt == 2) {
        char c = h(bits);
        ans += c;
        REP(i, C) {
          if (bs[i]) continue;
          if (as[i][j%as[i].size()] != c) {
            bs[i] = true;
          }
        }
      } else {
        break;
      }
    }
    cout << "Case #" << (testIndex + 1) << ": ";
    if (ok) {
      cout << ans << endl;
    } else {
      cout << "IMPOSSIBLE" << endl;
    }
  }
  return 0;
}
