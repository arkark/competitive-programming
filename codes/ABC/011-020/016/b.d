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
import std.ascii;
import std.datetime;

void main() {
    int A, B, C;
    readf("%d %d %d", &A, &B, &C);
    writeln(A+B==C&&A-B==C ? "?" : A+B==C ? "+" : A-B==C ? "-" : "!");
}
