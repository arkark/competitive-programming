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
    long[] ans = new long[31];
    ans[0] = 1;
    foreach(i; 1..31) {
        ans[i] += ans[i-1];
        if (i>1) ans[i] += ans[i-2];
        if (i>2) ans[i] += ans[i-3];
    }
    while(true) {
        int n = readln.chomp.to!int;
        if (n==0) break;
        writeln((ans[n]+3650-1)/3650);
    }
}
