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

struct Pos{int x, y;}
void main() {
    int[] input = readln.split.to!(int[]);
    int W = input[0];
    int H = input[1];
    int N = readln.chomp.to!int;
    Pos[] ary = N.iota.map!(_=> readln.split.to!(int[]).map!"a-1").map!(e => Pos(e[0], e[1])).array;

    int rec(int x1, int y1, int x2, int y2) {
        return reduce!max(0, ary.filter!(p => x1<=p.x && p.x<x2 && y1<=p.y && p.y<y2).map!(p =>
            memoize!rec(x1, y1, p.x, p.y) + memoize!rec(x1, p.y+1, p.x, y2) + memoize!rec(p.x+1, y1, x2, p.y) + memoize!rec(p.x+1, p.y+1, x2, y2) + x2-x1+y2-y1-1
        ));
    }
    rec(0, 0, W, H).writeln;
}
