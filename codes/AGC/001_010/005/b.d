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
void times(alias pred)(int n) {
    foreach(i; 0..n) pred();
}
auto rep(alias pred, T = typeof(pred()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

int INF = int.max/3;
void main() {
    int N = readln.chomp.to!int;
    int[] ary = readln.split.to!(int[]);
    int[] _ary = new int[N+1];
    foreach(i, e; ary) {
        _ary[e] = i.to!int;
    }
    int[] left = new int[N];
    int[] right = new int[N];

    auto rbtree = redBlackTree!((a,b)=>a>b, int)();
    foreach(i; 0..N) {
        while (!rbtree.empty && ary[i] < rbtree.front) {
            auto e = rbtree.front;
            rbtree.removeFront;
            right[_ary[e]] = abs(i-_ary[e])-1;
        }
        rbtree.insert(ary[i]);
    }
    while(!rbtree.empty) {
        auto e = rbtree.front;
        rbtree.removeFront;
        right[_ary[e]] = abs(N-_ary[e])-1;
    }

    foreach(j; 0..N) {
        auto i = N-j-1;
        while (!rbtree.empty && ary[i] < rbtree.front) {
            auto e = rbtree.front;
            rbtree.removeFront;
            left[_ary[e]] = abs(i-_ary[e])-1;
        }
        rbtree.insert(ary[i]);
    }
    while(!rbtree.empty) {
        auto e = rbtree.front;
        rbtree.removeFront;
        left[_ary[e]] = abs(-1-_ary[e])-1;
    }

    N.iota.map!(i => ary[i].to!long*(left[i]+1)*(right[i]+1)).sum.writeln;
}
