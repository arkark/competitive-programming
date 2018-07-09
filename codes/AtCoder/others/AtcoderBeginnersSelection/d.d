import std.stdio : readln, writeln;
import std.conv : to;
import std.range : repeat, back, generate, split, array;
import std.algorithm : map, countUntil, reduce, min;

void main() {
    (() => readln).repeat(2).map!"a()".array.back.split.to!(long[]).map!"a*2".map!(
        a => generate!(
            () => a /= 2
        ).countUntil!"a%2!=0"
    ).reduce!min.writeln;
}
