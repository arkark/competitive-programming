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

void main() {
    string[][] input = [readln.split, readln.split, readln.split];
    int R = input[0][0].to!int;
    int C = input[0][1].to!int;
    int X = input[1][0].to!int;
    int Y = input[1][1].to!int;
    int D = input[2][0].to!int;
    int L = input[2][1].to!int;

    long mod = 10^^9+7;
    long[][] dp = new long[][X*Y+1];
    foreach(int i; 0..X*Y+1) {
        dp[i] = new long[i+1];
        if (i==0) {
            dp[i][0] = 1;
        } else {
            foreach(int j; 0..i+1) {
                dp[i][j] = 0;
                if (j<i) dp[i][j] += dp[i-1][j];
                if (j>0) dp[i][j] += dp[i-1][j-1];
                dp[i][j] %= mod;
            }
        }
    }

    long ans = 0;
    foreach(int i; 0..2^^4) {
        int x = X;
        int y = Y;
        int count = 0;
        foreach(int j; 0..4) {
            if ((i>>j&1) == 1) {
                count++;
                if (j%2==0) y--;
                else x--;
            }
        }
        if (x*y >= D+L && x>0) {
            ans = (ans + dp[x*y][D]*dp[x*y-D][L]*(-1)^^count)%mod;
        }
    }
    if (ans < 0) ans += mod;
    writeln(ans*(R-X+1)*(C-Y+1)%mod);
}
