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

int[] dy = 3.iota.map!"a-1".repeat.take(3).array.join;
int[] dx = 3.iota.map!"a-1".map!(a => a.repeat.take(3).array).array.join;
void main() {
    long H, W;
    int N;
    readf("%d %d %d\n", &H, &W, &N);

    long[] ans = new long[10];

    int[int[2]] aa;
    N.times!({
        int a, b;
        readf("%d %d\n", &a, &b);
        a--; b--;
        foreach(i; 0..dy.length) {
            [a+dy[i], b+dx[i]].pipe!((int[2] p) {
                if (1<=p[0] && p[0]<H-1 && 1<=p[1] && p[1]<W-1) {
                    aa[p]++;
                }
            });
        }
    });

    foreach(v; aa.byValue) {
        ans[v]++;
    }
    ans[0] = (W-2)*(H-2) - aa.length;
    ans.each!writeln;
}
