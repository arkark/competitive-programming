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
    int N = readln.chomp.to!int;
    int[] R = new int[N];
    int[] H = new int[N];
    foreach(i; 0..N) {
        int[] input = readln.split.to!(int[]);
        R[i] = input[0]-1;
        H[i] = input[1]-1;
    }

    long[][] ary1 = new long[][](100000, 3);
    foreach(i; 0..N) {
        ary1[R[i]][H[i]]++;
    }
    long[] ary2 = new long[100000+1];
    foreach(i; 1..100000+1) {
        ary2[i] = ary2[i-1] + ary1[i-1].reduce!"a+b";
    }

    foreach(i; 0..N) {
        long a, b, c; // 勝, 負, 引
        a = ary2[R[i]] + ary1[R[i]][(H[i]+1)%3];
        b = ary2[100000] - ary2[R[i]+1] + ary1[R[i]][(H[i]+3-1)%3];
        c = ary1[R[i]][H[i]%3] - 1;
        writeln(a, " ", b, " ", c);
    }
}
