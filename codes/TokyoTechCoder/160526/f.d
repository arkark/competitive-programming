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
    while(true) {
        int W, H;
        readf("%d %d\n", &W, &H);
        if (W==0 && H==0) break;

        int N = readln.chomp.to!int;
        bool[][] flag = new bool[][](W, H);
        foreach(i; 0..N) {
            int[] input = readln.split.to!(int[]).map!"a-1".array;
            flag[input[0]][input[1]] = true;
        }

        long[][] dp = new long[][](W, H);
        dp[0][0] = 1;
        foreach(x; 0..W) foreach(y; 0..H) {
            if (flag[x][y]) continue;
            if (x>0) dp[x][y] += dp[x-1][y];
            if (y>0) dp[x][y] += dp[x][y-1];
        }
        dp.back.back.writeln;
    }
}
