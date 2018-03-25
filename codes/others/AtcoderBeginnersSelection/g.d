import std.stdio : readln, writeln;
import std.conv : to;
import std.range : array, back, enumerate, split, repeat;
import std.algorithm : map, sort, sum;

void main() {
    (() => readln).repeat(2).map!"a()".array.back.split.to!(long[]).sort!"a>b".enumerate.map!(
        a => a.value * (a.index%2==0 ? 1 : -1)
    ).sum.writeln;
}
