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
    int[] input = readln.split.to!(int[]);
    int N = input[0];
    int K = input[1];
    long[] ary = readln.split.to!(long[]);
    long s = ary[0..K].sum;
    long ans = s;
    foreach(i; 0..N-K) {
        s = s+ary[i+K]-ary[i];
        ans += s;
    }
    ans.writeln;
}
