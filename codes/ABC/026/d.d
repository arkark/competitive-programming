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
    int A, B, C;
    readf("%d %d %d\n", &A, &B, &C);
    auto f(double t) {
        return A*t + B*sin(C*t*PI);
    }

    double l=0, r=1000.0;
    foreach(_; 0..100000) {
        double c = (l+r)/2;
        if (f(c)<100.0) {
            l = c;
        } else {
            r = c;
        }
    }
    writefln("%0.10f", l);
}
