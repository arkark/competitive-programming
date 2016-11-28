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
    while(true) {
        int n = readln.chomp.to!int;
        if (n==0) break;
        (n/4).iota.map!(_ => readln.chomp.to!int).reduce!"a+b".writeln;
    }
}
