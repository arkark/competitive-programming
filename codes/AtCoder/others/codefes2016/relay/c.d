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
void times(alias pred)(int n) {
    foreach(i; 0..n) pred();
}
auto rep(alias pred, T = typeof(pred()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

void main() {
    int N = readln.chomp.to!int;
    long[] ary = new long[2^^(N+1)];

    foreach(i; 0..2^^N) {
        ary[2^^N-1+i] = readln.chomp.to!long;
    }
    for(int i=N-1; i>=0; i--) {
        foreach(j; 2^^i-1..2^^(i+1)-1) {
            ary[j] = f(ary[j*2+1], ary[j*2+2]);
        }
    }
    ary.front.writeln;
}

long f(long x, long y) {
    if (x==y) return x;
    return abs(x-y);
}
