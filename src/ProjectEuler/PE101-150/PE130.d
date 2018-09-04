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
    int N = 25;
    int[] ans = [];
    foreach(i; 2..1000000) {
        if (i%2 == 0) continue;
        if (i%5 == 0) continue;
        if ((i-1)%A(i) == 0 && !i.isPrime) {
            ans ~= i;
            if (ans.length == N) break;
        }
    }
    ans.writeln;
    ans.sum.writeln;
}

int A(int n) {
    /*if (gcd(n, 10) != 1) return -1;*/
    int x = 1;
    int i = 1;
    while(x != 0) {
        x = (x*10 + 1) % n;
        i++;
    }
    return i;
}

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
}

long modPow(long base, long power, long mod)  {
    BigInt bigBase = base.to!string();
    BigInt bigMod = mod.to!string();
    BigInt result = "1";
    for (; power > 0; power >>= 1) {
        if (power & 1) {
            result = (result * bigBase) % bigMod;
        }
        bigBase = (bigBase * bigBase) % bigMod;
    }
    return result.toLong();
}
