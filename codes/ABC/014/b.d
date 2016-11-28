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
import std.datetime;

void main() {
    int n, X;
    readf("%d %d\n", &n, &X);
    int[] ary = readln.split.to!(int[]);
    int ans = 0;
    foreach(i, e; ary) {
        if ((X>>i)&1) ans += e;
    }
    ans.writeln;
}
