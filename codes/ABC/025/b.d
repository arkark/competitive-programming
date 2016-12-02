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
    int N, A, B;
    readf("%d %d %d\n", &N, &A, &B);
    string[] dir = ["West", "East"];
    N.rep!({
        string s;
        int d;
        readf("%s %d\n", &s, &d);
        return max(A, min(B, d))  * (s==dir.front ? -1:1);
    }).fold!"a+b"(0).pipe!(x =>
        (x<0 ? dir.front~" " : x>0 ? dir.back~" " : "") ~ x.abs.to!string
    ).writeln;
}
