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
void times(alias fun)(int n) {
    foreach(i; 0..n) fun();
}
auto rep(alias fun, T = typeof(fun()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = fun();
    return res;
}



void main() {
    int N = 9;
    int ans = 0;
    foreach(long a; 1..10^^N) {
        if (a%1000000 == 0) a.writeln;
        if (a%10==0) continue;
        long b = a.to!(char[]).reverse.to!long;
        long c = a+b;
        while(c>0) {
            if (c%2==0) {
                break;
            } else {
                c /= 10;
            }
        }
        if (c==0) ans++;
    }
    ans.writeln;
}
