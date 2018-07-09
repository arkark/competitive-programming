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
void times(alias fun)(int n) {
    foreach(i; 0..n) fun();
}
auto rep(alias fun, T = typeof(fun()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = fun();
    return res;
}

void main() {
    int[] primes = getPrimes(1000000).to!(int[]);

    primes = primes[1] ~ primes[3..$]; // delete 2, 5

    int N = 40;
    int n = 10^^9;
    int[] ans = [];
    foreach(p; primes) {
        int x = 1;
        int i = 1;
        while(x != 0) {
            x = (x*10 + 1) % p;
            i++;
        }
        if (n%i == 0) {
            ans ~= p;
            if (ans.length == N) break;
        }
    }
    ans.writeln;
    ans.sum.writeln;
}

bool[] getIsPrimes(int limit) {
    bool[] isPrimes = new bool[limit+1];
    isPrimes[2..$] = true;
    for (int i=2; i*i<=isPrimes.length; i++) {
        if (isPrimes[i]) {
            for (int j=i*i; j<isPrimes.length; j+=i) {
                isPrimes[j] = false;
            }
        }
    }
    return isPrimes;
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
