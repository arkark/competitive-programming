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
    int M = 100000;
    int[] primes = getPrimes(M).to!(int[]);

    primes = primes[1] ~ primes[3..$]; // delete 2, 5

    int[] ans = [];
    foreach(p; primes) {
        int x = 1;
        int i = 1;
        while(x != 0) {
            x = (x*10 + 1) % p;
            i++;
        }
        while(true) {
            if (i%2 == 0) {
                i /= 2;
            } else if (i%5 == 0) {
                i /= 5;
            } else if (i == 1) {
                break;
            } else {
                ans ~= p;
                break;
            }
        }
    }
    ans.writeln;
    (ans.sum + 2 + 5).writeln;
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
