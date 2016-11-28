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
    int N, M;
    readf("%d %d\n", &N, &M);
    int[] f = N.iota.map!(_ => readln.chomp.to!int-1).array;
    f = f[0]~f;

    long[] dp = new long[N+1];
    dp[0] = 1;
    long sum = dp[0];
    int[] ary = new int[M];
    ary[f[0]]++;
    for(int i=1, j=0; i<=N; i++) {
        while(ary[f[i]]>1 || (ary[f[i]]==1 && f[j]!=f[i])) {
            ary[f[j]]--;
            sum = (sum+MOD-dp[j])%MOD;
            j++;
        }
        dp[i] = sum;
        sum = (sum+dp[i])%MOD;
        ary[f[i]]++;
    }
    dp.back.writeln;
}
