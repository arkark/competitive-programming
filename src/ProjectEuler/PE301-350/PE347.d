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
    int N = 10000000;
    int[] primes = getPrimes(N);

    auto tree = redBlackTree!("a<b", long)();
    auto stack = redBlackTree!("a<b", long)();

    foreach(i, long p; primes) {
        foreach(long q; primes[i+1..$]) {
            if (p*q > N) break;
            long po = 0;
            tree.clear;
            tree.insert([p*q]);
            while(!tree.empty) {
                long a = tree.front;
                tree.removeFront;
                po = max(po, a);
                if (a*p <= N) tree.insert(a*p);
                if (a*q <= N) tree.insert(a*q);
            }
            stack.insert(po);
        }
    }
    stack[].sum.writeln;
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
