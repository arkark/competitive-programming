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

void main() {
    int N, M;
    readf("%d %d\n", &N, &M);
    long[] ary = new long[M+1];
    foreach(i; 0..N) {
        int l, r; long s;
        readf("%d %d %d\n", &l, &r, &s);
        ary[0] += s;
        ary[l-1] -= s;
        ary[r] += s;
        ary[$-1] -= s;
    }
    foreach(i; 0..M) ary[i+1] += ary[i];
    ary.reduce!max.writeln;
}
