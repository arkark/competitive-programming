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
    long L = strs[0].to!long;
    long H = strs[1].to!long;
    int N = readln.chomp.to!int;
    foreach(int i; 0..N) {
        long A = readln.chomp.to!long;
        if (A > H) {
            writeln(-1);
        } else if (A > L) {
            writeln(0);
        } else {
            writeln(L - A);
        }
    }
}
