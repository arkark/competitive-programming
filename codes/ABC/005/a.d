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

void main() {
    string[] input = readln.split;
    int x = input[0].to!int;
    int y = input[1].to!int;
    writeln(y/x);
}
