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
        if (N==0) break;
        int[][] ary = new int[][N];
        foreach(i; 0..N) {
            ary[i] = readln.split.to!(int[]);
        }
        ary.sort!"a[1]>b[1]";
        int sum = reduce!"a+b[0]"(0, ary);
        foreach(i; 0..N) {
            if (sum > ary[i][1]) {
                writeln("No");
                break;
            }
            sum -= ary[i][0];
            if (sum==0) writeln("Yes");
        }
    }
}
