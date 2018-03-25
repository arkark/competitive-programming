import std.stdio : readln, writeln;
import std.conv : to;
import std.range : split, iota;
import std.algorithm : filter, map, sum;
import std.functional : pipe;

void main() {
    (
        as => iota(1, as[0]+1).filter!(
            x => x.to!string.map!(c => c.to!string.to!long).sum.pipe!(
                y => as[1]<=y && y<=as[2]
            )
        ).sum
    )(readln.split.to!(long[])).writeln;
}
