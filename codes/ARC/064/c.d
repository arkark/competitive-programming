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
import std.concurrency;
void times(alias fun)(int n) {
    foreach(i; 0..n) fun();
}
auto rep(alias fun, T = typeof(fun()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = fun();
    return res;
}
// fold was added in D 2.071.0.
template fold(fun...) if (fun.length >= 1) {
    auto fold(R, S...)(R r, S seed) {
        static if (S.length < 2) {
            return reduce!fun(seed, r);
        } else {
            return reduce!fun(tuple(seed), r);
        }
    }
}

void main() {
    int N; long x;
    readf("%d %d\n", &N, &x);
    long[] ary = readln.split.to!(long[]);
    N.iota.map!((i) {
        long s = max(0, ary[i]-x);
        ary[i] = min(ary[i], x);
        if (i>0) {
            s += max(0, ary[i]+ary[i-1]-x);
            ary[i] = min(ary[i], x-ary[i-1]);
        }
        return s;
    }).sum.writeln;
}
