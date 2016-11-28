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
    string[] input = readln.split;
    int N = input[0].to!int;
    long D = input[1].to!long;
    int[3] primes = [2, 3, 5];
    int[3] count  = new int[3];
    foreach(i, e; primes) {
        while(D%e==0) {
            D /= e;
            count[i]++;
        }
    }
    if (D!=1) {
        writeln(0);
        return;
    }
    double[int[3]][] dp = new double[int[3]][N+1];
    dp[0][[0, 0, 0]] = 1.0;
    foreach(i; 0..N) {
        foreach(k, v; dp[i]) {
            foreach(n; 1..6+1) {
                int _n = n;
                int[3] ary = [0, 0, 0];
                foreach(j, e; primes) {
                    while(_n%e==0) {
                        _n /= e;
                        ary[j]++;
                    }
                }
                ary[] += k[];
                foreach(j, ref e; ary) e = min(e, count[j]);
                dp[i+1][ary] += v;
            }
        }
    }
    writefln("%.7f", (count in dp[N]) ? dp[N][count]/(6.0^^N) : 0);
}
