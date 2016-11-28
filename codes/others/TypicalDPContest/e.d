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
    long MOD = 1000000007;
    int D = readln.chomp.to!int;
    int[] N = readln.chomp.to!(char[]).map!(a=>a-'0').array.to!(int[]);

    long[][][] dp = new long[][][](N.length+1, D, 2);
    dp[0][0][1] = 1;
    foreach(i; 0..N.length) foreach(j; 0..D) foreach(k; 0..2) {
        foreach(l; 0..(k==1 ? N[i]+1:10)) {
            if (k==1 && l==N[i]) {
                dp[i+1][(j+l)%D][1] = (dp[i+1][(j+l)%D][1]+dp[i][j][k])%MOD;
            } else {
                dp[i+1][(j+l)%D][0] = (dp[i+1][(j+l)%D][0]+dp[i][j][k])%MOD;
            }
        }
    }
    (dp[N.length][0].reduce!("a+b")-1).writeln;
}
