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
    int N = readln.chomp.to!int;
    foreach(int i; 0..N) {
        long[] input = readln.split.to!(long[]);
        long x = input[0];
        long y = input[1];
        long b = input[2];
        long p = input[3];

        long value1 = x*b + y*p;
        long value2 = (x*max(b, 5) + y*max(p, 2))*8/10;
        min(value1, value2).writeln;
    }
}
