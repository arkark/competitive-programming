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

int N;
long[][] ary;

void main() {
    N = readln.chomp.to!int;
    ary = N.rep!(() => readln.split.to!(long[]));
    ary.reverse();

    long l = 0;
    long r = 10L^^18;
    while(l < r) {
        long c = (l+r)/2;
        if (check(c)) {
            r = c;
        } else {
            if (l==c) break;
            l = c;
        }
    }
    r.writeln;
}

bool check(long c) {
    long[] res = ary.front.dup;
    if (c<res.sum) return false;
    res[] *= c/res.sum;
    foreach(e; ary) {
        if (res.front<e.front || res.back<e.back) return false;
        long r = min(res.front/e.front, res.back/e.back);
        res.front = r*e.front;
        res.back = r*e.back;
    }
    return true;
}
