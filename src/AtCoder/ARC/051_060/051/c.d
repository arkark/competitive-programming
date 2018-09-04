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

void main() {
    const long MOD = 10^^9+7;
    int[] input = readln.split.to!(int[]);
    int N = input[0];
    int A = input[1];
    int B = input[2];
    long[] ary = readln.split.to!(long[]).sort().array;
    int i; for(i=0; i<B && ary.front*A<ary.back; i++) {
        long temp = ary.front*A;
        size_t t = ary.length - ary.find!(a => a>=temp).length;
        ary = ary[0..t] ~ temp ~ ary[t..$];
        ary = ary[1..$];
        ary.sort();
    }
    foreach(j, ref e; ary) {
        e = e*modPow(A, (B-i)/N + (j<(B-i)%N ? 1:0), MOD)%MOD;
    }
    (ary[(B-i)%N..$]~ary[0..(B-i)%N]).each!writeln;
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
