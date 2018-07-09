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
    int[] n = readln.split.to!(int[]).sort;
    int Q = readln.chomp.to!int;
    int[] q = readln.split.to!(int[]).sort;
    int ans = 0;
    for(int i=0, j=0; i<N; i++) {
        while(j<Q && q[j]<=n[i]) {
            if (q[j]==n[i]) ans++;
            j++;
        }
    }
    ans.writeln;
}
