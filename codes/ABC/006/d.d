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

void main() {
    int N = readln.chomp.to!int;
    int[] c = new int[N];
    foreach(int i; 0..N) {
        c[i] = readln.chomp.to!int;
    }

    int[] dp = new int[N];
    dp[] = N+1; // inf
    foreach(int i; 0..N) {
        dp[N-dp.assumeSorted.upperBound(c[i]).length] = c[i];
    }
    writeln(N-dp.assumeSorted.lowerBound(N+1).length);
}
