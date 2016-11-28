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
    Pos s = Pos(input[0], input[1]);
    Pos g = Pos(input[2], input[3]);
    int T = input[4];
    int V = input[5];

    writeln(readln.chomp.to!int.iota.map!(_=>readln.split.to!(int[])).array.map!(a => Pos(a[0], a[1])).map!(p => length(p-s)+length(p-g)).canFind!(a => a<=T*V) ? "YES":"NO");
}

struct Pos{
    int x, y;
    Pos opBinary(string op)(Pos rhs) {
        mixin("return Pos(this.x" ~op~ "rhs.x, this.y" ~op~ "rhs.y);");
    }
}
double length(Pos p) {
    return sqrt(cast(double) (p.x^^2+p.y^^2));
}
