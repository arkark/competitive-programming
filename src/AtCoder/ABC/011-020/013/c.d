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
    long N, H, A, B, C, D, E;
    readf("%d %d\n%d %d %d %d %d", &N, &H, &A, &B, &C, &D, &E);
    (N+1).iota.map!(x => [x, (N-x)*E-H-B*x]).map!(a => [a[0], a[1]<0 ? 0 : a[1]/(D+E)+1]).filter!(a => a[0]+a[1]<=N).map!(a => a[0]*A+a[1]*C).reduce!min.writeln;
}
