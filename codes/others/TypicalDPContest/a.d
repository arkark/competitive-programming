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
    int N = readln.chomp.to!int;
    int[] input = readln.split.to!(int[]);
    bool[] dp = new bool[100*N+1];
    dp[0] = true;
    foreach(i; 0..N) {
        int p = input[i];
        bool[] _dp = dp.dup;
        foreach(j, e; _dp) {
            if (e) dp[j+p] = true;
        }
    }
    dp.count!(a=>a).writeln;
}
