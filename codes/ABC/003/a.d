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
    int N = readln.chomp.to!int;
    double ans = 0;
    foreach(int i; 0..N) {
        ans += (i+1)*10000;
    }
    writefln("%0.6f", ans/N);
}
