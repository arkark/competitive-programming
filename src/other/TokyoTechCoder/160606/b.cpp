#include<cstdio>
#include<iostream>
#include<algorithm>
#include<string>

using namespace std;

#define FOR(i,a,b) for (int i=(a);i<(b);i++)
#define RFOR(i,a,b) for (int i=(b)-1;i>=(a);i--)
#define REP(i,n) for (int i=0;i<(n);i++)
#define RREP(i,n) for (int i=(n)-1;i>=0;i--)

const int INF = 1<<25;
int dx[] = {-1,0,1,-1,0,1,-1,0,1};
int dy[] = {-1,-1,-1,0,0,0,1,1,1};
struct Pos{
    int x, y;
    Pos(int x=0, int y=0) {
        this->x = x;
        this->y = y;
    }
};
Pos p[9];
int N;
Pos ary[1000000];

int func(bool flg, Pos l, Pos r) {
    int res = 0;
    REP(i, N) {
        if (flg) { // right foot
            if (ary[i].x<l.x) {
                l = ary[i];
                flg = !flg;
                res++;
            } else {
                if (r.x==ary[i].x && r.y==ary[i].y) flg != flg;
                r = ary[i];
            }
        } else { // left foot
            if (ary[i].x>r.x) {
                r = ary[i];
                flg = !flg;
                res++;
            } else {
                if (l.x==ary[i].x && l.y==ary[i].y) flg != flg;
                l = ary[i];
            }
        }
        flg = !flg;
    }
    return res;
}

int solve() {
    string str;
    getline(cin, str);
    if (str=="#") return -1;

    N = str.length();
    REP(i, N) {
        ary[i] = p[str[i]-'1'];
    }
    int ans = INF;
    REP(i, 9) REP(j, 9) {
        ans = min(ans, min(func(false, p[i], p[j]), func(true, p[i], p[j])));
    }
    return ans;
}

int main() {
    REP(i, 9) {
        p[i] = Pos(dx[i], dy[i]);
    }

    int ans;
    while((ans = solve())>=0) {
        printf("%d\n", ans);
    }
    return 0;
}
