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

int x;
double p;
void main() {
    x = readln.chomp.to!int;
    p = readln.chomp.to!double/100.0;

    if (x>10) return;

    rec(0, 1.0).writeln;

}

double rec(int depth, double now) {
    if (depth==N-1)
}
