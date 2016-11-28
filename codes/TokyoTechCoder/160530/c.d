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
    int N, M;
    readf("%d", &N);
    int[] h = new int[N];
    int[] m = new int[N];
    foreach(i; 0..N) {
        readf(" %d %d", &h[i], &m[i]);
    }
    readf("\n%d", &M);
    int[] k = new int[M];
    int[] g = new int[M];
    foreach(i; 0..M) {
        readf(" %d %d", &k[i], &g[i]);
    }
    (zip(h, m).array~zip(k, g).array).sort!((a, b) => a[0]==b[0] ? a[1]<b[1] : a[0]<b[0]).uniq.map!(a => a[0].to!string~":"~("0"~a[1].to!string)[$-2..$]).join(" ").writeln;
}
