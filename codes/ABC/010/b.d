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
    int rec(int x) {
        if (x%2==1 || x%3==1) return 1+rec(x-1);
        return 0;
    }
    readln, readln.split.to!(int[]).map!"a-1".map!rec.reduce!"a+b".writeln;
}
