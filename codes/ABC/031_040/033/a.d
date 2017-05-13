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
    string N = readln.chomp;
    foreach(s; N) {
        if (s != N[0]) {
            writeln("DIFFERENT");
            return;
        }
    }
    writeln("SAME");
}
