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
    while (true) {
        int N = readln.chomp.to!int;
        if (N == 0) break;
        long[] k = readln.split.to!(long[]);

        if (k.filter!(a=>a>1).empty) {
            writeln("NA");
        } else {
            writeln(k.filter!(a=>a>0).array.length+1);
        }
    }
}
