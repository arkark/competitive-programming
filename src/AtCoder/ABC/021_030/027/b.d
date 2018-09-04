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
    readln.chomp.to!int.pipe!(N =>
        readln.split.to!(int[]).pipe!(ary =>
            ary.sum%N!=0 ? -1 : (N-1).iota.map!"a+1".count!((i){
                int s1 = ary[0..i].sum;
                int s2 = ary[i..$].sum;
                return s1%i!=0 || s2%(N-i)!=0 || s1/i!=s2/(N-i);
            }).to!int
        )
    ).writeln;
}
