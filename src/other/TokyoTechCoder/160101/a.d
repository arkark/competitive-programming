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
    int N = 100;
    int[] ary = new int[N+1];
    while(true) {
        auto input = readln.chomp;
        if (stdin.eof) break;
        ary[input.to!size_t]++;
    }
    int maximum = ary.reduce!(max);
    foreach(size_t i; 0..ary.length) if (ary[i]==maximum) i.writeln;
}
