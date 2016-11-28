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

void main() {
    int n, k;
    readf("%d\n%d", &n, &k);
    modComb(n+k-1, k, 10^^9+7).writeln;
}

long modComb(int n, int k, long mod) { // if (mod is prime)
    return modFact(n, mod)*modPow(modFact(k, mod), mod-2, mod)%mod*modPow(modFact(n-k, mod), mod-2, mod)%mod;
}

long modFact(int n, long mod) {
    if (n<1) return 1;
    return memoize!modFact(n-1, mod)*n%mod;
}

long modPow(long base, long power, long mod)  {
    long result = 1;
    for (; power > 0; power >>= 1) {
        if (power & 1) {
            result = (result * base) % mod;
        }
        base = base^^2 % mod;
    }
    return result;
}
