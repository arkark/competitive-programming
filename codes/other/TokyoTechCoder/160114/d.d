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

long INF = 1L<<60;
void main() {
    int[] input = readln.split.to!(int[]);
    int D = input[0];
    int N = input[1];
    int[] T = new int[D];
    foreach(i; 0..D) T[i] = readln.chomp.to!int;
    int[] A = new int[N];
    int[] B = new int[N];
    int[] C = new int[N];
    foreach(i; 0..N) {
        input = readln.split.to!(int[]);
        A[i] = input[0];
        B[i] = input[1];
        C[i] = input[2];
    }
    sort!("a[2]<b[2]")(zip(A, B, C));

    long[][] dp = new long[][](D, N);
    foreach(i; 0..D) {
        dp[i][] = -INF;
        foreach(j; 0..N) {
            if (A[j]<=T[i] && T[i]<=B[j]) {
                if (i==0) {
                    dp[i][j] = 0;
                } else {
                    foreach(k; 0..N) {
                        dp[i][j] = max(dp[i][j], dp[i-1][k]+abs(C[k]-C[j]));
                    }
                }
                break;
            }
        }
        foreach_reverse(j; 0..N) {
            if (A[j]<=T[i] && T[i]<=B[j]) {
                if (i==0) {
                    dp[i][j] = 0;
                } else {
                    foreach(k; 0..N) {
                        dp[i][j] = max(dp[i][j], dp[i-1][k]+abs(C[k]-C[j]));
                    }
                }
                break;
            }
        }
    }
    dp.back.reduce!max.writeln;
}
