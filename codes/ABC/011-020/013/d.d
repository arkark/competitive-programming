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

void main() {
    int N, M, D;
    readf("%d %d %d\n", &N, &M, &D);
    int[] ary = N.iota.array;
    foreach(e; readln.split.to!(int[]).reverse.map!"a-1") {
        swap(ary[e], ary[(e+1)%N]);
    }
    bool[] flag = new bool[N];

    int[][] cycles;
    foreach(i; 0..N) {
        if (flag[i]) continue;
        int[] cycle = [];
        int j = i;
        do {
            cycle ~= ary[j];
            j = cycle.back;
            flag[j] = true;
        } while(j!=i);
        cycles ~= cycle;
    }

    int[] ans = new int[N];
    foreach(cycle; cycles) {
        foreach(i, e; cycle) {
            ans[e] = cycle[(i+D)%$];
        }
    }
    foreach(e; ans.map!"a+1") e.writeln;
}
