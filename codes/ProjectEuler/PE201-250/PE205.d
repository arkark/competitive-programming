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
import std.concurrency;
import std.random;
void times(alias fun)(int n) {
    foreach(i; 0..n) fun();
}
auto rep(alias fun, T = typeof(fun()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = fun();
    return res;
}


void main() {
    int A = 4;
    int B = 6;

    int N = 9;
    int M = 6;

    double[] aryA = p(A, N);
    double[] aryB = p(B, M);

    double ans = 0.0;
    foreach(i, a; aryA) foreach(j, b; aryB) {
        if (i > j) ans += a*b;
    }
    writefln("%.8f", ans);
}

double[] p(int faceN, int cntN) {
    double[] res = new double[faceN*cntN + 1];
    res[0] = 1.0;
    res[1..$] = 0.0;
    foreach(i; 0..cntN) {
        foreach_reverse(int j; 0..res.length) {
            res[j] = 0.0;
            foreach(k; 0..faceN) {
                if (j-k-1 >= 0) res[j] += res[j-k-1]/faceN;
            }
        }
    }
    return res;
}
