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

int INF = 1<<30;
void main() {
    int[] input = readln.split.to!(int[]);
    int M = input[0];
    int N = input[1];
    int[][] data = new int[][](M, N);
    foreach(ref e; data) e = readln.split.to!(int[]);

}
