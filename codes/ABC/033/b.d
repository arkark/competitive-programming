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
    int N = readln.chomp.to!int;
    string[] S = new string[N];
    long[] P = new long[N];
    foreach(i; 0..N) {
        string[] input = readln.split;
        S[i] = input[0];
        P[i] = input[1].to!long;
    }
    long s = P.reduce!"a+b";
    foreach(i; 0..N) {
        if (P[i]*2 > s) {
            writeln(S[i]);
            return;
        }
    }
    writeln("atcoder");
}
