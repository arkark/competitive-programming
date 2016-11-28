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
    int ans = 0;
    foreach(i; 0..3) {
        int s, e;
        readf("%d %d\n", &s, &e);
        ans += s*e/10;
    }
    ans.writeln;
}
