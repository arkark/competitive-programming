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

int N, K;
int[][] ary;
void main() {
    readf("%d %d\n", &N, &K);
    ary = N.iota.map!(_ => readln.split.to!(int[])).array;
    writeln(rec() ? "Found":"Nothing");
}

bool rec(int depth = 0, int value = 0) {
    if (depth==N) return value==0;
    return K.iota.map!(i => rec(depth+1, value^ary[depth][i])).reduce!"a|b";
}
