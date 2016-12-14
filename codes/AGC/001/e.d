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
    int N, M;
    readf("%d %d\n", &N, &M);
    int[] ary = readln.split.to!(int[]).sort!((a, b) =>
        (a+b)%2==0 ? a<b : a%2==1
    ).array.pipe!"a[1..$]~a[0]";
    if (M==1) ary ~= 0;

    if (ary.count!"a%2==1" > 2) {
        writeln("Impossible");
        return;
    }

    ary.filter!"a>0".array.to!(string[]).join(" ").writeln;
    ary.front--;
    ary.back++;
    ary.filter!"a>0".array.pipe!((a) {
        a.length.writeln;
        a.to!(string[]).join(" ").writeln;
    });
}
