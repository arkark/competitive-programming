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
    int N = 10^^8;
    int[] primes = getPrimes(100000000);
    long[] aryS = new long[N+1];

    foreach(long p; primes) {
        long i = p;
        long j = 1;
        long k = p*j;
        while(i < aryS.length) {
            if (k%p == 0) {
                k /= p;
            } else {
                j++;
                k = p*j;
                k /= p;
            }
            aryS[i.to!int] = max(aryS[i.to!int], p*j);
            i *= p;
        }
    }

    foreach_reverse(i, s; aryS) {
        if (s == 0) continue;
        for(int j = i*2; j<aryS.length; j+=i) {
            aryS[j] = max(aryS[j], s);
        }
    }

    aryS.sum.writeln;
}

int[] getPrimes(int limit) {
    bool[] isPrimes = new bool[limit+1];
    isPrimes[2..$] = true;
    for (int i=2; i*i<=isPrimes.length; i++) {
        if (isPrimes[i]) {
            for (int j=i*i; j<isPrimes.length; j+=i) {
                isPrimes[j] = false;
            }
        }
    }
    int[] primes = [];
    foreach (i, flg; isPrimes) {
        if (flg) primes ~= i;
    }
    return primes;
}
