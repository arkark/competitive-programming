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
    int[] ary = [1,5,10,50,100,500];
    writeln(readln.split.to!(int[]).enumerate.map!(a => ary[a.index]*a.value).sum>=1000 ? 1: 0);
}
