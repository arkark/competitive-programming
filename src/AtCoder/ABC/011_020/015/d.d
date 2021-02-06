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

void main() {
    int W, N, K;
    readf("%d\n%d %d\n", &W, &N, &K);
    long[][] dp = new long[][](W+1, K+1);
    foreach(i; 0..N) {
        int a; long b;
        readf("%d %d\n", &a, &b);
        foreach_reverse(k; 0..min(i+1, K)) {
            foreach_reverse(w; 0..W+1-a) {
                dp[w+a][k+1] = max(dp[w+a][k+1], dp[w][k]+b);
            }
        }
    }
    dp.join.reduce!max.writeln;
}
