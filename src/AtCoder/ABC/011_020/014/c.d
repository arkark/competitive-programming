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
    int N = readln.chomp.to!int;
    int[] ary = new int[1000000+2];
    foreach(e; N.iota.map!(_ => readln.split.to!(int[]))) {
        ary[e[0]]++;
        ary[e[1]+1]--;
    }
    foreach(i; 1..ary.length) {
        ary[i] += ary[i-1];
    }
    ary.reduce!max.writeln;
}
