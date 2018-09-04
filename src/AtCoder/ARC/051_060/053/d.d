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
    const long MOD = 10^^9+7;
    int N = readln.chomp.to!int;
    int[] a = readln.split.to!(int[]).map!"a+1".array;
    int[] b = readln.split.to!(int[]).map!"a+1".array;

    long[][][] dp = new long[][][](2*(N-1), N, 4);
    dp[0][0][0] = 1;
    foreach(leng; 0..2*(N-1)) foreach(last; 0..N) foreach(mask; 0..4) {
        if (dp[len][last][mask]==0) continue;

    }
}
