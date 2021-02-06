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
    int a, b;
    readf("%d\n%d\n", &a, &b);
    writeln(min((a-b+10)%10, (b-a+10)%10));
}
