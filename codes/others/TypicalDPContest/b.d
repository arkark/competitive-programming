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
    int[] input = readln.split.to!(int[]);
    int A = input[0];
    int B = input[1];
    int[] a = readln.split.to!(int[]);
    int[] b = readln.split.to!(int[]);

    int[][] dp = new int[][](A+1, B+1);
    foreach(i; 1..A+B+1) {
        foreach(x; 0..i+1) {
            auto y = i-x;
            if (x>A || y>B) continue;
            if (x==0) {
                dp[x][y] = (A+B+i)%2 ? dp[x][y-1] : dp[x][y-1]+b[$-y];
            } else if (y==0) {
                dp[x][y] = (A+B+i)%2 ? dp[x-1][y] : dp[x-1][y]+a[$-x];
            } else {
                dp[x][y] = (A+B+i)%2 ? min(dp[x-1][y], dp[x][y-1]) : max(dp[x-1][y]+a[$-x], dp[x][y-1]+b[$-y]);
            }
        }
    }
    dp[A][B].writeln;
}
