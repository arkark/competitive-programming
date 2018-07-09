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

// 約数の個数をO(n^1/3)で求める
// http://pekempey.hatenablog.com/entry/2016/02/09/213718

void main() {
    int M = 1000;
    int[] primes = getPrimes(M);
    int[] ary = new int[primes.length];

    int N = 10^^7 + 1;
    int[] nums = new int[N];

    foreach(i; 0..N) {
        if (i%100000 == 0) i.writeln;
        int a = i+1;
        int k = 0;
        foreach(j; 0..primes.length) {
            int p = primes[j];
            if (p*p*p > i+1) break;
            if (a%p==0) {
                ary[k] = 1;
                while(a%p==0) {
                    a/=p;
                    ary[k]++;
                }
                k++;
            }
        }
        nums[i] = ary[0..k].fold!"a*b"(1);

        if (a == 1) {
            nums[i] *= 1;
        } else if (a.to!double.sqrt.pipe!(b => b-b.to!int) < 1e-5) {
            nums[i] *= 3;
        } else if (a.isPrime_MillerRabinTest(20)) {
            nums[i] *= 2;
        } else {
            nums[i] *= 4;
        }
    }

    int ans = 0;
    foreach(i; 0..N-1) {
        if (nums[i] == nums[i+1]) {
            ans++;
        }
    }
    ans.writeln;
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

bool isPrime_MillerRabinTest(long n, int k) {
    if (n == 2) return true;
    if (n < 2 || !(n&1)) return false;

    long d = n-1;
    int s = 0;
    for (; d & 1; d>>=1, s++){}

    bool flg = true;
    Random rnd = Random(unpredictableSeed);
    for (int i=0; i<k && flg; i++) {
        long a = uniform(1, n, rnd);
        long r = modPow(a, d, n);
        if (r == 1 || r == n-1) continue;
        flg = false;
        for (int j=0; j<s && !flg; j++) {
            r = modPow(r, 2, n);
            if (r == n-1) flg = true;
        }
        if (!flg) return false;
    }
    return true;
}

long modPow(long base, long power, long mod)  {
    long result = 1;
    for (; power > 0; power >>= 1) {
        if (power & 1) {
            result = (result * base) % mod;
        }
        base = (base * base) % mod;
    }
    return result;
}
