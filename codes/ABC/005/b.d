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

void main() {
    int N = readln.chomp.to!int;
    int[] T = new int[N];
    foreach(int i; 0..N) {
        T[i] = readln.chomp.to!int;
    }
    reduce!((a, b)=>a<b ? a:b)(100, T).writeln;
}
