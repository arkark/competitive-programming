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

void main() {
    int h1, w1, h2, w2;
    readf("%d %d\n%d %d", &h1, &w1, &h2, &w2);
    writeln(h1==h2 || w1==w2 || h1==w2 || w1==h2 ? "YES":"NO");
}
