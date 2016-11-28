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
    string input = readln.chomp;
    switch(input) {
        case "1 0 0": case "0 1 0": case "0 0 0": {
            writeln("Close");
        } break;
        default: {
            writeln("Open");
        } break;
    }
}
