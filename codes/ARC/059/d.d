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
    readln.chomp.enumerate.array.pipe!(
        s =>
        ((s.length==2 && s.front.value==s.back.value) ? [[1, 2]] : []) ~ (s.length-2).iota.map!(
            i => s[i..i+3]
        ).map!(
            a => (a[0].value==a[1].value || a[1].value==a[2].value || a[2].value==a[0].value) ? [a[0].index+1, a[2].index+1].to!(int[]) : [-1, -1]
        ).array
    ).fold!(
        (a, b) => a && (b.front<0 || (writeln(b.front, " ", b.back), false))
    )(true) && writeln("-1 -1");
}
