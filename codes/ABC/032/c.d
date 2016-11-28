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
    long[] s = new long[N];
    foreach(ref e; s) e = readln.chomp.to!long;

    if (s.canFind(0)) {
        s.length.writeln;
        return;
    }

    int m = 0;
    long num = 1;
    int i=0;
    foreach(j; 0..N) {
        num *= s[j];
        while(num > K && i<=j) {
            num /= s[i++];
        }
        if (num <= K) {
            m = max(m, j-i+1);
        }
    }
    m.writeln;
}
