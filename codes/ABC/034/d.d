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

struct A{double w, p;}
void main() {
    int N, K;
    readf("%d %d\n", &N, &K);

    A[] ary = new A[N];
    foreach(i; 0..N) {
        int w, p;
        readf("%d %d\n", &w, &p);
        ary[i] = A(w, p/100.0);
    }

    double getV(A a, double t) {
        return a.w * (a.p - t);
    }

    double l = 0.0;
    double r = 100.0;
    foreach(_; 0..10000) {
        double c = (l+r)/2;
        if (ary.map!(a => getV(a, c)).array.sort!"a>b".take(K).sum > 0.0) {
            l = c;
        } else {
            r = c;
        }
    }
    writefln("%0.10f", l*100.0);
}
