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
    int N, a, b, K;
    readf("%d\n%d %d\n%d\n", &N, &a, &b, &K);
    writeln((readln.split.to!(int[])~a~b).sort.group.canFind!"a[1]>1" ? "NO" : "YES");
}
