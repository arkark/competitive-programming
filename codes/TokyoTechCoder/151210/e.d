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
    int[char] aa = ['J':0, 'O':1, 'I':2];
    int N = readln.chomp.to!int;
    string str = readln.chomp;
    int[] dp = new int[2^^3];
    dp[1] = 1;
    foreach(char c; str) {
        int[] _dp = dp.dup;
        dp[] = 0;
        foreach(int i; 0..2^^3) foreach(int j; 0..2^^3) {
            if ((i&j)!=0 && (j&1<<aa[c])!=0) {
                dp[j] = (_dp[i]+dp[j])%10007;
            }
        }
    }
    reduce!("(a+b)%10007")(0, dp).writeln;
}
