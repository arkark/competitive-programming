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
        int[] h = readln.split.to!(int[]);

        foreach(i; 0..h.length) {
            int[] _h = h[0..i] ~ h[i+1..$];
            int[] sa = new int[n-1];
            foreach(j, ref e; sa) {
                e = _h[j+1]-_h[j];
            }
            if (sa.count!(a=>a==sa[0]) == sa.length) {
                writeln(h[i]);
                break;
            }
        }
    }
}
