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

void main() {
    int N, A;
    readf("%d %d\n", &N, &A);
    int[] ary = readln.split.to!(int[]);
    long[][] dp = new long[][](N+1, A*N+1);
    dp[0][0] = 1;
    foreach(i; 0..N) {
        foreach(j; iota(1, N+1).retro) {
            foreach(k; (A*N+1).iota.retro) {
                if (k-ary[i] >= 0) dp[j][k] += dp[j-1][k-ary[i]];
            }
        }
    }
    dp.enumerate[1..$].map!(a => a.value[a.index*A]).sum.writeln;
}
