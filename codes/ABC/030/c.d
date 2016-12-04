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

void main() {
    int N, M;
    readf("%d %d\n", &N, &M);
    long[] time = readln.split.to!(long[]);
    auto trees = 2.rep!(() =>
        redBlackTree!((a, b) => a<b, true, long)(readln.split.to!(long[]))
    );
    long ans = 0;
    long t = 0;
    int now = 0;
    while(!trees[now].empty) {
        long a = trees[now].front;
        trees[now].removeFront;
        if (a>=t) {
            t = a+time[now];
            now = (now+1)%2;
            ans++;
        }
    }
    (ans/2).writeln;
}
