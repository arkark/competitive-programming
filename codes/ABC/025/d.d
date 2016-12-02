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
import core.bitop;
void times(alias fun)(int n) {
    foreach(i; 0..n) fun();
}
auto rep(alias fun, T = typeof(fun()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = fun();
    return res;
}
// fold was added in D 2.071.0.
template fold(fun...) if (fun.length >= 1) {
    auto fold(R, S...)(R r, S seed) {
        static if (S.length < 2) {
            return reduce!fun(seed, r);
        } else {
            return reduce!fun(tuple(seed), r);
        }
    }
}

int MOD = 10^^9+7;
void main() {
    int N = 5;
    int[] grid = N.rep!(() => readln.split.to!(int[]).map!"a-1").join.array;
    int[] ary = (N*N).iota.map!(i => grid.countUntil(i)).array.to!(int[]);

    bool isSpace(int i, uint bits) {
        if ((1<<i&bits) != 0) return false;
        bool flgX = i%N==0 || i%N==N-1 || ((1<<(i-1)&bits)==0) == ((1<<(i+1)&bits)==0);
        bool flgY = i/N==0 || i/N==N-1 || ((1<<(i-N)&bits)==0) == ((1<<(i+N)&bits)==0);
        return flgX && flgY;
    }

    int[] dp = new int[1<<(N*N)];
    dp.front = 1;
    foreach(k; 0..N*N) {
        uint bits = (1<<k)-1;
        for (; (1<<(N*N)&bits)==0; bits = nextBits(bits)) {
            if (dp[bits]==0) continue;
            if (ary[k]<0) {
                foreach(i; 0..N*N) {
                    if (isSpace(i, bits)) {
                        dp[1<<i | bits] = (dp[1<<i | bits] + dp[bits]) % MOD;
                    }
                }
            } else {
                if (isSpace(ary[k], bits)) {
                    dp[1<<ary[k] | bits] = (dp[1<<ary[k] | bits] + dp[bits]) % MOD;
                }
            }
            if (bits==0x0u) break;
        }
    }
    dp.back.writeln;
}

// reference: http://alexbowe.com/popcount-permutations/
int nextBits(int v) {
    int t = (v | ( v - 1)) + 1;
    int w = t | ((((t & -t) / (v & -v)) >> 1) - 1);
    return w;
}
