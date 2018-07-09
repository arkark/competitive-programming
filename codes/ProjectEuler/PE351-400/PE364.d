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

long MOD = 100000007;
void main() {
    int N = readln.chomp.to!int;

    long ans = 0;
    foreach(i; 0..N) {
        ans += rec(new int[N], i, N-i-1);
        ans %= MOD;
    }
    ans.writeln;
}

long rec(int[] ary, int left, int right) {
    foreach_reverse(i, e; ary) {

    }
}
