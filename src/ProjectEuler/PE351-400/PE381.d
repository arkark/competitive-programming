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

// ウィルソンの定理

void main() {
    int N = 10^^8;
    long
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
    foreach (int i, flg; isPrimes) {
        if (flg) primes ~= i;
    }
    return primes;
}
