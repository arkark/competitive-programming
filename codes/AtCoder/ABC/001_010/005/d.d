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

long[][] dp;
void main() {
    int N = readln.chomp.to!int;
    long[][] D = new long[][N];
    foreach(int i; 0..N) D[i] = readln.split.to!(long[]);
    int Q = readln.chomp.to!int;
    int[] P = new int[Q];
    foreach(int i; 0..Q) P[i] = readln.chomp.to!int;

    dp = new long[][N];
    foreach(int i; 0..N) {
        dp[i] = D[i].dup;
        foreach(int j; 1..N) dp[i][j] += dp[i][j-1];
        if (i > 0) {
            foreach(int j; 0..N) dp[i][j] += dp[i-1][j];
        }
    }
    long[] max = new long[N*N+1];
    foreach(int x; 0..N) foreach(int y; 0..N) foreach(int width; 1..N-x+1) foreach(int height; 1..N-y+1) {
        long value = func(x, y, width, height);
        if (value > max[width*height]) max[width*height] = value;
    }
    foreach(int i; 1..N*N+1) {
        if (max[i-1] > max[i]) max[i] = max[i-1];
    }
    foreach(int i; 0..Q) {
        max[P[i]].writeln;
    }
}
long func(int x, int y, int width, int height) {
    long result = 0;
    result += dp[x+width-1][y+height-1];
    if (x>0) result -= dp[x-1][y+height-1];
    if (y>0) result -= dp[x+width-1][y-1];
    if (x>0 && y>0) result += dp[x-1][y-1];
    return result;
}
