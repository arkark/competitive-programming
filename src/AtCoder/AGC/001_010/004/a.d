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

long calc(long x, long y) {
    return abs(x/2 - (x-x/2))*y;
}

void main() {
    long a, b, c;
    readf("%d %d %d", &a, &b, &c);
    min(calc(a, b*c), calc(b, c*a), calc(c, a*b)).writeln;
}
