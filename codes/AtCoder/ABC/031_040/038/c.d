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
    int N = readln.chomp.to!int;
    int[] ary = readln.split.to!(int[]);
    long ans = 0;
    long sum;
    foreach(i; 0..N) {
        if (i>0 && ary[i]>ary[i-1]) {
            sum++;
        } else {
            sum=1;
        }
        ans += sum;
    }
    ans.writeln;
}
