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

struct Vertex{
    int next;
    bool visited;
}
void main() {
    int N, a;
    readf("%d %d\n", &N, &a);
    a--;
    BigInt k = readln.chomp;
    Vertex[] vs = readln.split.to!(int[]).map!"a-1".map!(b => Vertex(b)).array;
    int[] ary = [];
    for(int i=0; !vs[a].visited; i++) {
        ary ~= a;
        vs[a].visited = true;
        a = vs[a].next;
    }
    ary ~= a;
    int x = ary.countUntil(a).to!int;
    int y = ary[x+1..$].countUntil(a).to!int+1;
    writeln(k<x ? ary[k.toInt]+1 : ary[x + ((k-x)%y)]+1);
}
