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
    int[] ary = N.iota.map!(_ => readln.chomp.to!int).array;
    writefln("%.6f", ary.map!(e => ary.count!(a => e%a==0)).map!(e => e%2==0 ? 0.5 : (e+1)/cast(double)(2*e)).reduce!"a+b");
}
