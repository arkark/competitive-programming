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

double EPS = 1e-10;
void main() {
    int N = readln.chomp.to!int;
    Vertex[] vs = N.rep!(() => readln.split.to!(int[]).pipe!(a => Vertex(a.front, a.back))).array;
    long[] ans = [0, 0, 0]; // 鋭角、直角、鈍角
    foreach(o; vs) {
        auto ary = vs.filter!(v => v!=o).map!(v => v-o).map!(v => v.angle).array.sort().pipe!(a => a.array ~ a.map!(b => b+2.0*PI).array.to!(double[])).assumeSorted;
        ans[1] += ary[0..$/2].map!(a =>
            ary.length.to!int
             - ary.upperBound(a+PI/2.0+EPS).length.to!int
             - ary.lowerBound(a+PI/2.0-EPS).length.to!int
        ).sum;
        ans[2] += ary[0..$/2].map!(a =>
            ary.length.to!int
             - ary.upperBound(a+PI+EPS).length.to!int
             - ary.lowerBound(a+PI/2.0+EPS).length.to!int
        ).sum;
    }
    ans[0] = N.to!long*(N-1)*(N-2)/6 - ans[1] - ans[2];
    ans.to!(string[]).join(" ").writeln;
}

struct Vertex{
    int x, y;
    double angle() {
        return atan2(y.to!double, x.to!double);
    }
    Vertex opBinary(string op)(Vertex that) {
        mixin("return Vertex(this.x"~op~"that.x, this.y"~op~"that.y);");
    }
}
