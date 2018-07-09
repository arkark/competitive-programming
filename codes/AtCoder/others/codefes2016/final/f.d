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
void times(alias fun)(int n) {
    foreach(i; 0..n) fun();
}
auto rep(alias fun, T = typeof(fun()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = fun();
    return res;
}
// fold was added in D 2.071.0.
template fold(fun...) if (fun.length >= 1) {
    auto fold(R, S...)(R r, S seed) {
        static if (S.length < 2) {
            return reduce!fun(seed, r);
        } else {
            return reduce!fun(tuple(seed), r);
        }
    }
}

long MOD = 10^^9+7;
void main() {
    int N, M;
    readf("%d %d\n", &N, &M);

    long[][][] dp = (M+1).iota.map!(i => (min(i+1, N)+1).iota.map!(j => (j+1).iota.map!(k => 0L).array).array).array;
    dp[0][1][1] = 1;
    foreach(i; 0..M) foreach(j; 0..min(i+1, N)+1) foreach(k; 0..j+1) {
        if (j<N) dp[i+1][j+1][k].add(dp[i][j][k] * (N-j));
        dp[i+1][j][k].add(dp[i][j][k] * (j-k));
        dp[i+1][j][j].add(dp[i][j][k] * k);
    }
    dp.back.back.back.writeln;
}
void add(ref long v1, long v2) {
    v1 = (v1 + v2)%MOD;
}
