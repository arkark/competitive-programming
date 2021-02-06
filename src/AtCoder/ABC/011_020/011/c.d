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

const int INF = 1<<30;
void main() {
    int N = readln.chomp.to!int;
    bool[] flag = new bool[N+3];
    foreach(i; 0..3) {
        int ng = readln.chomp.to!int;
        if (ng <= N) flag[ng] = true;
    }
    int[] dp = new int[N+3];
    dp[1..$] = INF;
    foreach(i; 0..N) {
        foreach(j; 1..3+1) {
            if (!flag[i+j]) dp[i+j] = min(dp[i+j], dp[i]+1);
        }
    }
    writeln(dp[N]<=100 ? "YES":"NO");
}
