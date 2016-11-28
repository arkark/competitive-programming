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

void main() {
    int N, M;
    readf("%d %d\n", &N, &M);

    int[][] ary = new int[][N];
    M.times({
        int x, y;
        readf("%d %d\n", &x, &y);
        x--; y--;
        ary[x] ~= y;
    });

    long[] dp = new long[1<<N];
    dp[0] = 1;
    foreach(i; 0..1<<N) {
        foreach(j; 0..N) {
            if (!(i>>j&1)) continue;
            if(ary[j].all!(k =>!(i>>k&1))) dp[i] += dp[(~(1<<j))&i];
        }
    }
    dp.back.writeln;
}
