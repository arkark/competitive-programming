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
    int N = 10^^6;
    foreach(i; 999999..int.max) {
        if (A(i) > N) {
            writeln(i);
            break;
        }
    }
}

int A(int n) {
    if (gcd(n, 10) != 1) return -1;
    int x = 1;
    int i = 1;
    while(x != 0) {
        x = (x*10 + 1) % n;
        i++;
    }
    return i;
}
