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

void times(int n, void delegate() pred) {
    foreach(i; 0..n) pred();
}
T[] rep(T)(int n, T delegate() pred) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

long INF = 1L<<60;
void main() {
    int N = readln.chomp.to!int;
    long[] a = readln.split.to!(long[]);
    long[] dp = new long[N];
    dp[1..$] = INF;
    foreach(i; 0..N) {
        foreach(j; 0..2) {
            if (i>j) dp[i] = min(dp[i], dp[i-j-1]+abs(a[i]-a[i-j-1]));
        }
    }
    dp.back.writeln;
}
