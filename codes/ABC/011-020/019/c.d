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
    readln;
    bool[int] aa;
    int[] ary = readln.split.to!(int[]).map!((a) {
        while(a%2==0) a/=2;
        return a;
    }).array;
    foreach(a; ary) aa[a] = true;
    aa.length.writeln;
}
