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
    ["dream", "dreamer", "erase", "eraser"].map!(s => s.retro.to!(char[])).pipe!((ary) {
        char[] str = readln.chomp.retro.to!(char[]);
        while({
            if (str.empty) return false;
            foreach(e; ary) {
                size_t s = e.length;
                if (str.length>=s && str[0..s]==e) {
                    str = str[s..$];
                    return true;
                }
            }
            return false;
        }()){}
        return str.empty;
    }).pipe!(a =>a?"YES":"NO").writeln;
}
