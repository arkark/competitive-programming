import std.stdio;
import std.string;
import std.conv;
import std.typecons;
import std.algorithm;
import std.functional;
import std.bigint;
import std.numeric;
import std.array;
import std.math;
import std.range;
import std.container;
import std.ascii;
void times(alias pred)(int n) {
    foreach(i; 0..n) pred();
}
auto rep(alias pred, T = typeof(pred()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

struct Pos{
    int r, c;
    Pos opBinary(string op)(Pos rhs) {
        mixin("return Pos(this.r" ~op~ "rhs.r, this.c" ~op~ "rhs.c);");
    }
}

int R, C, N;
int[Pos] aa;
bool updateFlg = true;
void main() {
    readf("%d %d\n%d\n", &R, &C, &N);
    N.times!({
        int r, c, a;
        readf("%d %d %d\n", &r, &c, &a);
        r--; c--;
        aa[Pos(r, c)] = a;
    });

    bool ans = true;
    while(updateFlg) {
        updateFlg = false;
        if (!solve()) ans = false;
    }
    writeln(ans ? "Yes" : "No");
}

int INF = int.max/3;

bool isInner(Pos p) {
    if (p.r<0)  return false;
    if (p.r>=R) return false;
    if (p.c<0)  return false;
    if (p.c>=C) return false;
    return true;
}

bool check(Pos p1, Pos p2, Pos p3, Pos p4) {
    int cnt = 1;
    if (p2 in aa) cnt++;
    if (p3 in aa) cnt++;
    if (p4 in aa) cnt++;
    if (cnt==4) {
        if (aa[p1]+aa[p3] != aa[p2]+aa[p4]) return false;
    } else if (cnt==3) {
        if (p2 !in aa) {
            int v = aa[p1]+aa[p3]-aa[p4];
            if (v < 0) {
                return false;
            } else {
                aa[p2] = v;
                updateFlg = true;
            }
        }
        if (p3 !in aa) {
            int v = aa[p2]+aa[p4]-aa[p1];
            if (v<0) {
                return false;
            } else {
                aa[p3] = v;
                updateFlg = true;
            }
        }
        if (p4 !in aa) {
            int v = aa[p1]+aa[p3]-aa[p2];
            if (v<0) {
                return false;
            } else {
                aa[p4] = v;
                updateFlg = true;
            }
        }
    } else {
        if (p3.isInner && p3 !in aa) {
            aa[p3] = INF;
            updateFlg = true;
        } else if (p2.isInner && p2 !in aa) {
            aa[p2] = INF;
            updateFlg = true;
        } else if (p4.isInner && p4 !in aa) {
            aa[p4] = INF;
            updateFlg = true;
        }
    }
    return true;
}

bool solve() {

    foreach(p1, v; aa) {
        // 右下
        {
            Pos p2 = p1+Pos(1, 0);
            Pos p3 = p1+Pos(1, 1);
            Pos p4 = p1+Pos(0, 1);

            if (!check(p1, p2, p3, p4)) return false;
        }
        // 左下
        {
            Pos p2 = p1+Pos(0, 1);
            Pos p3 = p1+Pos(-1, 1);
            Pos p4 = p1+Pos(-1, 0);

            if (!check(p1, p2, p3, p4)) return false;
        }
        // 左上
        {
            Pos p2 = p1+Pos(-1, 0);
            Pos p3 = p1+Pos(-1, -1);
            Pos p4 = p1+Pos(0, -1);

            if (!check(p1, p2, p3, p4)) return false;
        }
        // 右上
        {
            Pos p2 = p1+Pos(0, -1);
            Pos p3 = p1+Pos(1, -1);
            Pos p4 = p1+Pos(1, 0);

            if (!check(p1, p2, p3, p4)) return false;
        }
    }

    return true;
}
