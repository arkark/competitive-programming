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
    int N, K;
    readf("%d %d\n", &N, &K);
    Vertex[] vs = N.rep!(() => new Vertex).pipe!((vs) {
        int[] ary = readln.split.to!(int[]).map!"a-1".array;
        ary.enumerate.each!((a) {
            vs[a.value].p = ary[a.value];
            vs[a.value].q = a.index.to!int;
        });
        return vs;
    });

    
}

class Vertex {
    int p;
    int q;
    int cnt;
    bool checked;
    Edge[] edges;
    /*this(int p, int q) {
        this.p = p;
        this.q = q;
    }*/
    override string toString() {
        return [p, q].to!string;
    }
}

struct Edge {
    Vertex start, end;
}
