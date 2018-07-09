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
    long N = readln.chomp.to!long;
    long d = N.pipe!(n => 2.repeat.map!(a => n/=2).countUntil!(_ => n==0));
    d.iota.map!(i =>
        (long a) => (i+d)%2==0 ? a*2+1 : a*2
    ).fold!((a, f) => f(a))(1L).pipe!(x =>
        (x>N) != (d%2==0) ? "Aoki" : "Takahashi"
    ).writeln;
}
