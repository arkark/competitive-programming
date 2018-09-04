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
    int[] input = readln.split.to!(int[]);
    int N = input[0];
    int Q = input[1];
    int[] ary = new int[N+1];
    foreach(i; 0..Q) {
        input = readln.split.to!(int[]);
        ary[input[0]-1]++;
        ary[input[1]]--;
    }
    foreach(i; 0..N) {
        if (i>0) ary[i] += ary[i-1];
        write(ary[i]%2);
    }
    "".writeln;
}
