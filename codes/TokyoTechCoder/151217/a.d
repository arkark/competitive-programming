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
        long[] input = readln.split.to!(long[]);
        if (stdin.eof) break;
        long gcd = gcd(input[0], input[1]);
        writeln(gcd, " ", input[0]*input[1]/gcd);
    }
}
