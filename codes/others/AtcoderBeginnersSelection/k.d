import std.stdio : readln, writeln;
import std.conv : to;
import std.string : chomp;
import std.range : front, back, repeat, split, zip, array;
import std.algorithm : map, all;
import std.math : abs;
import std.functional : pipe;

void main() {
    ([0L, 0L, 0L] ~ (() => readln.split.to!(long[])).repeat(readln.chomp.to!long).map!"a()".array).pipe!(
        as => zip(as[0..$-1], as[1..$])
    ).map!(
        a => zip(a[0], a[1]).map!(
            b => abs(b[1]-b[0])
        )
    ).all!(
        as => as[0] >= as[1]+as[2] && as[0]%2 == (as[1]+as[2])%2
    ).pipe!(
        a => a ? "Yes" : "No"
    ).writeln;
}
