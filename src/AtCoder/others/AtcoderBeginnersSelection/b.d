import std.stdio : readln, writeln;
import std.conv : to;
import std.range : split;
import std.algorithm : reduce;
import std.functional : pipe;

void main() {
    ["Even", "Odd"][readln.split.to!(long[]).reduce!"a*b".pipe!"a%2"].writeln;
}
