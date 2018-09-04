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

long INF = long.max/3;
void main() {
    int N, A, B;
    readf("%d %d %d\n", &N, &A, &B);
    int S = 10*100 + 1;
    long[][] dp = S.rep!(() => S.rep!(() => INF));
    dp[0][0] = 0;
    foreach(_; 0..N) {
        int a, b, c;
        readf("%d %d %d\n", &a, &b, &c);
        foreach(i; (S-a).iota.retro) foreach(j; (S-b).iota.retro) {
            dp[i+a][j+b] = min(dp[i+a][j+b], dp[i][j] + c);
        }
    }

    long ans = INF;
    foreach(i; 1..S) foreach(j; 1..S) {
        if (i*B == j*A) ans = min(ans, dp[i][j]);
    }
    writeln(ans==INF?-1:ans);
}

// ----------------------------------------------

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
