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
import std.datetime;
void times(int n, void delegate() pred) {
    foreach(i; 0..n) pred();
}
T[] rep(T)(int n, T delegate() pred) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

immutable MAX = 10^^6;
void main() {
    int N, T;
    readf("%d %d\n", &N, &T);
    int[] ary = new int[MAX+T+1];
    N.times({
        int a = readln.chomp.to!int-1;
        ary[a]++;
        ary[a+T]--;
    });
    foreach(i, ref e; ary) {
        if (i==0) continue;
        e += ary[i-1];
    }
    ary.count!"a>0".writeln;
}
