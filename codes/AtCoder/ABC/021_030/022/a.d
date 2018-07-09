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
void times(int n, void delegate() pred) {
    foreach(i; 0..n) pred();
}
T[] rep(T)(int n, T delegate() pred) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

void main() {
    int N, S, T, w;
    readf("%d %d %d\n%d\n", &N, &S, &T, &w);
    N.iota.map!(i => i==0 ? w : (w=w+readln.chomp.to!int)).count!(a => S<=a && a<=T).writeln;
}
