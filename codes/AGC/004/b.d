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
void times(alias pred)(int n) {
    foreach(i; 0..n) pred();
}
auto rep(alias pred, T = typeof(pred()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

void main() {
    int N;
    long x;
    readf("%d %d\n", &N, &x);
    long[] a = readln.split.to!(long[]);
    a.reverse();

    long[][] ary = N.iota.map!(i => N.iota.map!(j => a[(i+j)%$]).array).array;
    foreach(i; 0..N) foreach(j; 1..N) {
        ary[i][j] = min(ary[i][j], ary[i][j-1]);
    }

    N.iota.map!(k => k*x + ary.map!(e => e[k]).sum).reduce!min.writeln;
}
