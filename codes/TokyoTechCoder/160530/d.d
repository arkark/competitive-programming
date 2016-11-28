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
    int N, M, p;
    readf("%d %d %d\n", &N, &M, &p);
    int[] d = new int[M];
    foreach(i; 0..M) d[i] = readln.chomp.to!int;
    d = d.map!(a=>(a-p+N)%N).array.sort;
    (iota(-1, M).map!(i => [i<0?0:d[i], i+1>=M?0:N-d[i+1]]).map!(a => min(a[0]*2+a[1], a[0]+a[1]*2)).reduce!min*100).writeln;
}
