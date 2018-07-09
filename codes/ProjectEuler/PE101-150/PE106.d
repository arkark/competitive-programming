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
    int N = 12;
    int M = N/2;

    long[][] dp = new long[][](M, 2*M-1);
    dp[0][0] = 1;
    foreach(i; 1..M) {
        foreach(j; i..2*i+1) {
            foreach(k; i..j+1) {
                dp[i][j] += dp[i-1][k-1];
            }
        }
    }
    foreach(i; 0..M) {
        foreach(j; 1..2*i+1) {
            dp[i][j] += dp[i][j-1];
        }
    }

    long[][] comb = new long[][](N+1, N+1); // iCj == comb[i][j]
    foreach(i; 0..N+1) {
        foreach(j; 0..i+1) {
            if (i<1 || j==0 || j==i) {
                comb[i][j] = 1;
            } else {
                comb[i][j] = comb[i-1][j-1] + comb[i-1][j];
            }
        }
    }

    long ans = 0;
    foreach(i; 0..M) {
        ans += comb[N][2*(i+1)] * (comb[2*(i+1)][i+1]/2 - dp[i][2*i]);
    }
    ans.writeln;
}
