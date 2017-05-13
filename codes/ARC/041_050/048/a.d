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
    int[] a = readln.split.to!(int[]);
    if (a[0]<0) a[0]++;
    if (a[1]<0) a[1]++;
    writeln(a[1]-a[0]);
}
