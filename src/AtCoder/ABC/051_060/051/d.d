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

long INF = long.max/3;
struct Edge{int fst, snd; long cost;}
void main() {
    int N, M;
    readf("%d %d\n", &N, &M);
    long[][] d = N.iota.map!(i => N.iota.map!(j => i==j?0:INF).array).array;
    Edge[] es = new Edge[M];
    foreach(i; 0..M) {
        int a, b; long c;
        readf("%d %d %d\n", &a, &b, &c);
        a--; b--;
        d[a][b] = c;
        d[b][a] = c;
        es[i] = Edge(a, b, c);
    }
    foreach(k; 0..N) {
        foreach(i; 0..N) foreach(j; 0..N) {
            d[i][j] = min(d[i][j], d[i][k] + d[k][j]);
        }
    }
    es.count!(
        e => N.iota.all!(
            i => d[i][e.fst] + e.cost != d[i][e.snd]
        )
    ).writeln;
}

// -------------------------------------------
void times(alias fun)(int n) {
    foreach(i; 0..n) fun();
}
auto rep(alias fun, T = typeof(fun()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = fun();
    return res;
}

// fold was added in D 2.071.0
static if (__VERSION__ < 2071) {
    template fold(fun...) if (fun.length >= 1) {
        auto fold(R, S...)(R r, S seed) {
            static if (S.length < 2) {
                return reduce!fun(seed, r);
            } else {
                return reduce!fun(tuple(seed), r);
            }
        }
    }
}

// minElement/maxElement was added in D 2.072.0
static if (__VERSION__ < 2072) {
    auto minElement(alias map, Range)(Range r)
    if (isInputRange!Range && !isInfinite!Range)
    {
        alias mapFun = unaryFun!map;
        auto element = r.front;
        auto minimum = mapFun(element);
        r.popFront;
        foreach(a; r) {
            auto b = mapFun(a);
            if (b < minimum) {
                element = a;
                minimum = b;
            }
        }
        return element;
    }
    auto maxElement(alias map, Range)(Range r)
    if (isInputRange!Range && !isInfinite!Range)
    {
        alias mapFun = unaryFun!map;
        auto element = r.front;
        auto maximum = mapFun(element);
        r.popFront;
        foreach(a; r) {
            auto b = mapFun(a);
            if (b > maximum) {
                element = a;
                maximum = b;
            }
        }
        return element;
    }
}
