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
    int L = readln.chomp.to!int;
    double A = readln.chomp.to!double;
    double B = readln.chomp.to!double;
    double C = readln.chomp.to!double;
    double D = readln.chomp.to!double;
    writeln(L-max((A/C).ceil, (B/D).ceil));
}
