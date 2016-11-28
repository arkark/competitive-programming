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
    int[][] ary = new int[][](3, N);
    foreach(i; 0..N) {
        int[] input = readln.split.to!(int[]);
        foreach(j; 0..3) {
            ary[j][i] = input[j];
        }
    }
    foreach(i; 0..N) {
        int ans = 0;
        foreach(j; 0..3) {
            if (!(ary[j][0..i]~ary[j][i+1..$]).canFind(ary[j][i])) ans += ary[j][i];
        }
        ans.writeln;
    }
}
