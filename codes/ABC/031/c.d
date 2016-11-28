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

void main() {
    int N = readln.chomp.to!int;
    long[] a = readln.split.to!(long[]);

    long ans = -10000000;
    foreach (int i; 0..N) {
        long x, y;
        long maxX = -10000000;
        long maxY = -10000000;
        foreach (int j; 0..N) {
            if (i == j) continue;
            x = 0;
            y = 0;
            long[] b;
            if (i<j) b = a[i..j+1];
            else b = a[j..i+1];
            for (int k=0; k<b.length; k++) {
                if (k%2==0) { // 奇数
                    x += b[k];
                } else { // 偶数
                    y += b[k];
                }
            }
            if (y > maxY) {
                maxY = y;
                maxX = x;
            }
        }
        if (maxX > ans) ans = maxX;
    }
    ans.writeln;
}
