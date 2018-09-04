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

void main() {
    int L, X, Y, S, D;
    readf("%d %d %d %d %d\n", &L, &X, &Y, &S, &D);
    double a = Y+X;
    double b = Y-X;
    double ans = (D-S+L)%L/a;
    if (b>0) ans = min(ans, (S-D+L)%L/b);
    writefln("%.6f", ans);
}
