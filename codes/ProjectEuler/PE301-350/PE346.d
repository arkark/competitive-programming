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
import std.random;
void times(alias fun)(int n) {
    foreach(i; 0..n) fun();
}
auto rep(alias fun, T = typeof(fun()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = fun();
    return res;
}

struct A{long a, b;}
void main() {
    long N = 10L^^12;

    long f(long i) {
        return (i + 1L)*i + 1L;
    }

    auto tree = redBlackTree!(
        (a, b) => a.a!=b.a ? a.a<b.a : a.b<b.b,
    )(A(f(2L), 2L));

    writeln("po");

    long ans = 0;
    int i=0;
    long now = 3L;
    while(!tree.empty && tree.front.a<N) {
        if (i%1000000 == 0) writeln(i, " ", tree.front.a);
        i++;
        auto s = tree.front;
        tree.removeFront;
        long a = s.a*s.b + 1L;
        if (a<N) tree.insert(A(a, s.b));
        while(!tree.empty && s.a==tree.front.a) {
            auto _s = tree.front;
            tree.removeFront;
            long _a = _s.a*_s.b + 1L;
            if (_a<N) tree.insert(A(_a, _s.b));
        }
        ans += s.a;

        if ((!tree.empty && tree.front.a>=f(now)) || (tree.empty && now<N)) {
            tree.insert(A(f(now), now));
            now++;
        }
    }

    ans += 1L;
    ans.writeln;
}
