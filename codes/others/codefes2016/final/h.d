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
import std.traits;
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

int MAX = 10^^6+1;
void main() {
    int N = readln.chomp.to!int;
    int[] a = readln.split.to!(int[]);

    auto list = DList!int(MAX.iota);
    iota(2, N-1).each!(i => list[].drop(1).take(a[i]).each!(v => list.insertFront(v)));
    int[] ary = list[].array;
    int s = a[2..$].sum;
    int M = readln.chomp.to!int;
    foreach(_; 0..M) {
        int x = readln.chomp.to!int;
        writeln((x<MAX ? ary[x] : x-s) + a[0] - a[1]);
    }
}
