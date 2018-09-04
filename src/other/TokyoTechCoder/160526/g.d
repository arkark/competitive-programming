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
    for(int i=1; ; i++) {
        int W = readln.chomp.to!int;
        if (W==0) break;
        writeln("Case "~i.to!string~":");

        int[] dp = new int[W+1];
        int N = readln.chomp.to!int;
        N.iota.map!(_=>readln.chomp.split(",").to!(int[])).each!((a) {
            int v = a[0];
            int w = a[1];
            foreach_reverse(j; w..W+1) {
                if (j==w || dp[j-w]>0) dp[j] = max(dp[j], dp[j-w]+v);
            }
        });
        int m = dp.reduce!max;
        m.writeln;
        dp.countUntil(m).writeln;
    }
}
