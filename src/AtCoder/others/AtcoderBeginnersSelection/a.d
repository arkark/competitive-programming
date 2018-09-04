import std.stdio : readln, writeln;
import std.conv : to;
import std.range : join, split, repeat;
import std.algorithm : map, sum;
import std.string : chomp;
import std.container : make, Array;

void main() {
    (() => readln.split.to!(long[])).repeat(2).map!"a()".join.sum.to!string.make!Array(readln.chomp)[].join(" ").writeln;
}
