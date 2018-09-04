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
    int[] input = readln.split.to!(int[]);
    int W = input[0];
    int H = input[1];
    int N = input[2];
    int ans = 0;
    int[] point = readln.split.to!(int[]);
    foreach(int i; 1..N) {
        int[] _point = readln.split.to!(int[]);
        int dx = _point[0]-point[0];
        int dy = _point[1]-point[1];
        if (dx*dy > 0) {
            dx = abs(dx);
            dy = abs(dy);
            ans += min(dx, dy) + abs(dx-dy);
        } else {
            ans += abs(dx)+abs(dy);
        }
        point = _point;
    }
    ans.writeln;
}
