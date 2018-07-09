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
        long[] t = new long[N];
        foreach(int i; 0..N) {
            t[i] = readln.chomp.to!long;
        }
        t.sort;
        long ans = 0;
        long sum = 0;
        foreach(int i; 0..N) {
            ans += sum;
            sum += t[i];
        }
        ans.writeln;
    }

}
