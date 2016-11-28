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

void main() {
    long MOD = 1000000007;
    int[] input = readln.split.to!(int[]);
    int N = input[0], K = input[1];

    long[] dp = new long[N+2];
    dp[0] = 1;
    long sum = 1;
    foreach(i; 1..dp.length) {
        if (i!=1 && i!=N) dp[i] = sum;
        sum = (sum+dp[i]) % MOD;
        if (i>=K) sum = (sum-dp[i-K]+MOD)%MOD;
    }
    dp.back.writeln;
}
