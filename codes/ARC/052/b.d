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
    const int MAX = 2*10^^4 + 1;
    int[] input = readln.split.to!(int[]);
    int N = input[0];
    int Q = input[1];
    double[] ary = new double[MAX];
    ary[] = 0;
    foreach(i; 0..N) {
        input = readln.split.to!(int[]);
        int X = input[0];
        int R = input[1];
        int H = input[2];
        foreach(x; X..X+H) {
            double t = ((X+H-x)/cast(double)H)^^3 - ((X+H-x-1)/cast(double)H)^^3;
            ary[x] += PI*R^^2*H*t/3.0;
        }
    }
    foreach(i, ref e; ary) {
        if (i==0) continue;
        e += ary[i-1];
    }

    foreach(i; 0..Q) {
        input = readln.split.to!(int[]);
        int A = input[0];
        int B = input[1];
        writefln("%.4f", (B==0 ? 0:ary[B-1]) - (A==0 ? 0:ary[A-1]));
    }
}
