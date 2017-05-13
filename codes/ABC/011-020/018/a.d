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
    int[] ary = new int[3];
    readf("%d\n%d\n%d", &ary[0], &ary[1], &ary[2]);
    foreach(e; ary) {
        ary.count!(a => a>=e).writeln;
    }
}
