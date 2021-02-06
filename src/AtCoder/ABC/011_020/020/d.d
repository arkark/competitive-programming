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

long MOD = 10^^9+7;
void main() {
    long N, K;
    readf("%d %d", &N, &K);

    long[] divisors = (n){
        long[] result;
        for(long i=1; i*i<=n; i++) {
            if (n%i!=0) continue;
            result ~= i;
            result ~= n/i;
        }
        return result.sort.uniq.array;
    }(K);
    long[] ary = new long[divisors.length];
    foreach_reverse(i, divisor; divisors) {
        long num = N/divisor;
        ary[i] = (divisor+num*divisor)*num/2;
        foreach(j; i+1..divisors.length) {
            if (divisors[j]%divisor == 0) ary[i]-=ary[j];
        }
    }
    (reduce!((a, b) => (a+b[0]/b[1])%MOD)(0L, zip(ary, divisors))*K%MOD).writeln;
}
