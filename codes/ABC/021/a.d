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
    N.writeln;
    N.iota.map!(_=>(writeln(1), _)).array;
}
