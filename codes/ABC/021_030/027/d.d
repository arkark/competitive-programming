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
    string str = readln.chomp;
    int N = str.length.to!int;
    int[] cnt = new int[N];
    foreach(i; N.iota.retro) {
        if (i==0) continue;
        cnt[i-1] = cnt[i];
        if (str[i]=='+') cnt[i-1] = cnt[i]+1;
        if (str[i]=='-') cnt[i-1] = cnt[i]-1;
    }
    zip(N.iota, str).filter!(a => a[1]=='M').map!(a => cnt[a[0]]).array.sort().array.pipe!(ary =>
        ary[$/2..$].sum - ary[0..$/2].sum
    ).writeln;
}
