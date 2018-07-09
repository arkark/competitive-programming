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
    int[string] aa;
    foreach(i; 0..N) {
        aa[readln.chomp]++;
    }
    aa.keys.map!(a => tuple(a, aa[a])).array.sort!"a[1]>b[1]".front[0].writeln;
}
