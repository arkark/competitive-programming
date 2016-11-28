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

void main() {
    int[] data = array(map!(to!int)(readln.split));
    writeln(data[0]>data[1] ? data[0]:data[1]);
}
