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
    reduce!((x, y) => [max(x[0], x[1]+y[0]), x[1]+y[0]-y[1]])(
        [0L, 0L],
        readln.chomp.to!int.iota.map!(_ => readln.split.to!(long[])).array.sort!((x, y) {
            if (x[0]<x[1] && y[0]<y[1]) return x[0]<y[0];
            if (x[0]>=x[1] && y[0]>=y[1]) return x[1]>y[1];
            return x[0]<x[1];
        })
    )[0].writeln;
}
