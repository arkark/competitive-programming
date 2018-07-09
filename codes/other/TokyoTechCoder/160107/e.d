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
        int n = readln.chomp.to!int;
        if (n==0) break;
        long[] p = readln.split.to!(long[]);
        long[] j = readln.split.to!(long[]);

        int[] ary = (n-1).iota.array;
        sort!((a,b)=>a[1]>b[1])(zip(ary, j.dup));
        long sum = p.sum;
        long num = n;
        foreach(e; ary) {
            if ((sum+j[e])*(num-1) > sum*num) {
                sum += j[e];
                num--;
            } else {
                break;
            }
        }
        writeln(sum*num);
    }
}
