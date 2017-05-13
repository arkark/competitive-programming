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

void main() {
    int x1, y1, x2, y2;
    readf("%d %d %d %d\n", &x1, &y1, &x2, &y2);
    int dx = x2-x1;
    int dy = y2-y1;
    [
        "L",
        "U".repeat(dy+1).join,
        "R".repeat(dx+1).join,
        "D",

        "L".repeat(dx).join,
        "D".repeat(dy).join,

        "R".repeat(dx).join,
        "U".repeat(dy).join,

        "R",
        "D".repeat(dy+1).join,
        "L".repeat(dx+1).join,
        "U"
    ].join.writeln;
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

// fold was added in D 2.071.0.
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
