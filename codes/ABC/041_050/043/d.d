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

void main() {
    true.reduce!(
        (a, b) => a && (b.front<0 || (writeln(b.front, " ", b.back), false))
    )(readln.chomp.enumerate.array.pipe!(
        s =>
        ((s.length==2 && s.front.value==s.back.value) ? [[1, 2]] : []) ~ (s.length-2).iota.map!(
            i => s[i..i+3]
        ).map!(
            a => (a[0].value==a[1].value || a[1].value==a[2].value || a[2].value==a[0].value) ? [a[0].index+1, a[2].index+1].to!(int[]) : [-1, -1]
        ).array
    )) && writeln("-1 -1");
}
