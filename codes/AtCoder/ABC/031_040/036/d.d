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

long MOD = 10^^9+7;
void main() {
    int N = readln.chomp.to!int;
    Vertex[] vs = N.rep!(() => new Vertex);
    (N-1).times!({
        int a, b;
        readf("%d %d\n", &a, &b);
        a--; b--;
        vs[a].edges ~= Edge(vs[a], vs[b]);
        vs[b].edges ~= Edge(vs[b], vs[a]);
    });

    Vertex root = vs.find!(a => a.edges.length>1).front;

    void rec(Vertex v) {
        v.visited = true;
        Vertex[] ary = v.edges.map!"a.end".filter!"!a.visited".array;
        ary.each!rec;
        v.value2 = ary.map!"a.value1".fold!((a, b) => a*b%MOD)(1L);
        v.value1 = (v.value2 + ary.map!"a.value2".fold!((a, b) => a*b%MOD)(1L)) % MOD;
    }

    rec(root);
    root.value1.writeln;
}

class Vertex {
    bool visited;
    long value1, value2;
    Edge[] edges;
}

struct Edge {
    Vertex start, end;
}
