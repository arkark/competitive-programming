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
    long n = readln.chomp.to!long;
    long s = readln.chomp.to!long;

    if (n == s) {
        (n+1).writeln;
        return;
    }
    long t = n.to!double.sqrt.to!long+2;
    foreach(b; 2..t) {
        if (check(b, n, s)) {
            b.writeln;
            return;
        }
    }
    foreach(p; iota(1, t).retro) {
        long b = (n-s)/p + 1;
        if (check(b, n, s)) {
            b.writeln;
            return;
        }
    }

    (-1).writeln;
}

bool check(long b, long n, long s) {
    long f(long b, long n) {
        return n%b + (n<b ? 0 : f(b, n/b));
    }
    return b>1 && f(b, n) == s;
}
