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
    while(true) {
        int N = readln.chomp.to!int;
        if (N == 0) break;

        int[][] ans = [[-1, -1]];
        readln.split.to!(int[]).each!((a) {
            if (a == ans.back.back+1) {
                ans.back.back++;
            } else {
                ans ~= [a, a];
            }
        });
        ans[1..$].map!(a => a.front==a.back ? a.front.to!string : a.front.to!string~"-"~a.back.to!string).reduce!((a, b) => a~" "~b).writeln;
    }
}
