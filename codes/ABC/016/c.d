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

const int INF = 1<<25;
void main() {
    int N, M;
    readf("%d %d\n", &N, &M);
    int[][] dist = N.iota.map!(i => N.iota.map!(j => i==j ? 0:INF).array).array;
    foreach(_; 0..M) {
        int[] input = readln.split.to!(int[]).map!"a-1".array;
        dist[input[0]][input[1]] = 1;
        dist[input[1]][input[0]] = 1;
    }
    foreach(k; 0..N) foreach(i; 0..N) foreach(j; 0..N) {
        dist[i][j] = min(dist[i][j], dist[i][k]+dist[k][j]);
    }
    foreach(i; 0..N) {
        N.iota.count!(j => dist[i][j]==2).writeln;
    }
}
