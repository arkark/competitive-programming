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
    string[] strs = readln.split;
    int A = strs[0].to!int;
    int D = strs[1].to!int;
    int x = (A+1)*D;
    int y = A*(D+1);
    writeln(x>y?x:y);
}
