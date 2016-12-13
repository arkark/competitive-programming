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

struct Pos{
    int index;
    long x, y;
    bool checked;
}
long dist(Pos p1, Pos p2) {
    return max(abs(p1.x-p2.x), abs(p1.y-p2.y));
}

long INF = long.max/3;
void main() {
    int N, a, b;
    readf("%d %d %d\n", &N, &a, &b);
    a--; b--;
    Pos[] ps = N.iota.map!((i) => readln.split.array.to!(long[]).pipe!(a => Pos(i, a.front+a.back, a.front-a.back))).array;
    auto rbtree1 = redBlackTree!((a, b) =>
        a.x!=b.x ? a.x<b.x : a.y<b.y
    )(ps);
    auto _rbtree1 = rbtree1.dup;
    auto rbtree2 = redBlackTree!((a, b) =>
        a.y!=b.y ? a.y<b.y : a.x<b.x
    )(ps);
    auto _rbtree2 = rbtree2.dup;

    long ans = 0;
    long d = dist(ps[a], ps[b]);

    ps[a].checked = true;
    ps[b].checked = true;
    auto list = DList!int([a, b]);
    auto f = (int i) {
        if (!ps[i].checked) {
            list.insertBack(i);
            ps[i].checked = true;
        }
    };
    while(!list.empty) {
        int t = list.front; list.removeFront;
        with(ps[t]) {
            auto l1 = rbtree1.lowerBound(Pos(-1, x-d, y-d)).array.length.to!int;
            auto r1 = N-rbtree1.upperBound(Pos(-1, x-d, y+d-1)).array.length.to!int;
            ans += (r1-l1).abs;
            auto _ary1 = _rbtree1.lowerBound(Pos(-1, x-d, y-d)).array ~ _rbtree1.upperBound(Pos(-1, x-d, y+d-1)).array;
            _ary1.map!(p => p.index).each!f;
            _rbtree1.clear; _rbtree1.insert(_ary1);

            int l2 = rbtree1.lowerBound(Pos(-1, x+d, y-d+1)).array.length.to!int;
            int r2 = N-rbtree1.upperBound(Pos(-1, x+d, y+d)).array.length.to!int;
            ans += (r2-l2).abs;
            auto _ary2 = _rbtree1.lowerBound(Pos(-1, x+d, y-d+1)).array ~ _rbtree1.upperBound(Pos(-1, x+d, y+d)).array;
            _ary2.map!(p => p.index).each!f;
            _rbtree1.clear; _rbtree1.insert(_ary2);

            int l3 = rbtree2.lowerBound(Pos(-1, x-d+1, y-d)).array.length.to!int;
            int r3 = N-rbtree2.upperBound(Pos(-1, x+d, y-d)).array.length.to!int;
            ans += (r3-l3).abs;
            auto _ary3 = _rbtree2.lowerBound(Pos(-1, x-d+1, y-d)).array ~ _rbtree2.upperBound(Pos(-1, x+d, y-d)).array;
            _ary3.map!(p => p.index).each!f;
            _rbtree2.clear; _rbtree2.insert(_ary3);

            int l4 = rbtree2.lowerBound(Pos(-1, x-d, y+d)).array.length.to!int;
            int r4 = N-rbtree2.upperBound(Pos(-1, x+d-1, y+d)).array.length.to!int;
            ans += (r4-l4).abs;
            auto _ary4 = _rbtree2.lowerBound(Pos(-1, x-d, y+d)).array ~ _rbtree2.upperBound(Pos(-1, x+d-1, y+d)).array;
            _ary4.map!(p => p.index).each!f;
            _rbtree2.clear; _rbtree2.insert(_ary4);
        }
    }
    ans.pipe!"a/2".writeln;
}
