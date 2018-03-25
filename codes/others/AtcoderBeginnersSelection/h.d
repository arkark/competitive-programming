import std.stdio : readln, writeln;
import std.conv : to;
import std.string : chomp;
import std.range : array, split, repeat;
import std.algorithm : map, sort, uniq, count;

void main() {
    (() => readln.split.to!(long[])).repeat(readln.chomp.to!long).map!"a()".array.sort!"a>b".uniq.count.writeln;
}
