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
    int N = readln.chomp.to!int;
    N.dur!"seconds".writeln;
    writefln("%02d:%02d:%02d", N/3600, N/60%60, N%60);
}
