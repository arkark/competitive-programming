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

int INF = 1<<25;
struct Box{int w, h;}
void main() {
    int N = readln.chomp.to!int;
    int[] dp = INF.repeat(N).array;
    N.iota.map!(_=>readln.split.to!(int[])).map!(a=>Box(a[0], a[1])).array.sort!((a, b) => a.w==b.w ? a.h>b.h : a.w<b.w).map!(box => box.h).each!(h => dp[dp.assumeSorted.lowerBound(h).length] = h);
    dp.count!(a => a<INF).writeln;
}
