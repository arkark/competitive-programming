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
    foreach(int i;1..10) foreach(int j; 1..10) {
        writeln(i, "x", j, "=", i*j);
    }
}
