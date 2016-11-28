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
    int K = readln.chomp.to!int;
    int[] R = new int[2^^K];
    foreach(ref e; R) e = readln.chomp.to!int;
    double[][] dp = new double[][](K+1, 2^^K);
    foreach(ref e; dp) e[] = 0.0;
    dp[0][] = 1.0;
    foreach(i; 0..K) {
        foreach(j; 0..2^^(K-i-1)) {
            foreach(k; 0..2^^(i)) foreach(l; 2^^(i)..2^^(i+1)) {
                int _k = j*2^^(i+1)+k;
                int _l = j*2^^(i+1)+l;
                dp[i+1][_k] += dp[i][_k]*dp[i][_l]*getProbability(R[_k], R[_l]);
                dp[i+1][_l] += dp[i][_l]*dp[i][_k]*getProbability(R[_l], R[_k]);
            }
        }
    }
    foreach(i; 0..2^^K) {
        writefln("%.7f", dp[$-1][i]);
    }
}
double getProbability(int p, int q) {
    return 1.0/(1.0 + 10.0^^((q-p)/400.0));
}
