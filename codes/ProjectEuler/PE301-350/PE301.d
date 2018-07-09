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

void main() {
    // 石取りゲーム(Nim)
    // 三山崩し

    int ans = 0;
    for(int n=1; n<=2^^30; n++) {
        if ((n ^ n*2 ^ n*3) == 0) ans++;
    }
    ans.writeln;
}
