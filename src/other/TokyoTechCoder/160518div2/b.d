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
    foreach(i; 1..1000000) {
        int n = readln.chomp.to!int;
        if (n==0) break;
        writeln("Case "~i.to!string~": "~n.to!string);
    }
}
