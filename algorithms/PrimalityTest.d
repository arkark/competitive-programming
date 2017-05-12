import std.stdio;
import std.random;
import std.conv;
import std.string;
import std.bigint;
import std.math;

// 強擬素数 3215031751
void main() {
    long r = readln().chomp().to!long();
    r.isPrime().writeln();
}



long modPow(long base, long power, long mod)  {
    long result = 1;
    for (; power > 0; power >>= 1) {
        if (power & 1) {
            result = (result * base) % mod;
        }
        base = (base * base) % mod;
    }
    return result.toLong();
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

/*
bool isPrime(long n) {
    if (n == 2) return true;
    if (n < 2 || !(n&1)) return false;
    for (long i=3; i*i<=n; i+=2) {
        if (n%i == 0) return false;
    }
    return true;
}*/

/*// ミラーラビン素数判定法の決定的アルゴリズム版
bool isPrime(long n) {
    if (n == 2) return true;
    if (n < 2 || !(n&1)) return false;

    long d = n-1;
    int s = 0;
    for (; d & 1; d>>=1, s++){}

    bool flg = true;
    real k = 2*(log(n))^^2;
    if (n-1 < k) k = n-1;
    for (int i=2; i<=k && flg; i++) {
        long a = i;
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
}*/
