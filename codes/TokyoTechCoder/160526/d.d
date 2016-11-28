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

int N;
int[] ary;
void main() {
    while(true) {
        N = readln.chomp.to!int;
        if (N==0) break;
        ary = readln.split.to!(int[]);
        rec(0, 0).writeln;
    }
}
int rec(int depth, int x) {
    if (depth==N) return x.abs;
    return min(rec(depth+1, x+ary[depth]), rec(depth+1, x-ary[depth]));
}
