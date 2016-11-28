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
    int[][] dist = new int[][](N, N);
    foreach(i; 0..N) dist[i][0..i] = INF, dist[i][i+1..$] = INF;
    foreach(i; 0..M) {
        int a, b, t;
        readf("%d %d %d\n", &a, &b, &t);
        dist[a-1][b-1] = t;
        dist[b-1][a-1] = t;
    }
    foreach(k; 0..N) foreach(i; 0..N) foreach(j; 0..N) {
        dist[i][j] = min(dist[i][j], dist[i][k]+dist[k][j]);
    }
    N.iota.map!(i => dist[i].reduce!max).array.reduce!min.writeln;
}
