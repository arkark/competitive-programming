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
import std.random;
void times(alias fun)(int n) {
    foreach(i; 0..n) fun();
}
auto rep(alias fun, T = typeof(fun()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = fun();
    return res;
}

void main() {
    int N = 14;
    long limit = 10L^^N;

    long ans = 0;
    void f(long num, long s, bool strong) {
        foreach(i; 0..10) {
            long _num = num*10 + i;
            long _s = s + i;
            if (_num >= limit) continue;
            if (_s == 0) continue;
            if (strong && _num.isPrime) {
                ans += _num;
            } else if (_num%_s == 0) {
                bool _strong = (_num/_s).isPrime;
                f(_num, _s, _strong);
            }
        }
    }
    f(0, 0, false);
    ans.writeln;
}

bool isPrime(long n) {
    if (n == 2) return true;
    if (n < 2 || !(n&1)) return false;
    for (long i=3; i*i<=n; i+=2) {
        if (n%i == 0) return false;
    }
    return true;
}
