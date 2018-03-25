import std.stdio : readln, writeln;
import std.conv : to;
import std.range : split, iota, join, only, tee, array, front;
import std.algorithm : map, reduce;

void main() {
    (
        as => false.reduce!(
            (exists, bs) => exists || (
                10000*bs[0] + 5000*bs[1] + 1000*bs[2] == as[1] && (
                    true.only.tee!(
                        _ => bs.map!(to!string).join(" ").writeln
                    ).array.front
                )
            )
        )(
            0.iota(as[0]+1).map!(
                i => 0.iota(as[0]-i+1).map!(
                    j => [i, j, as[0]-i-j]
                )
            ).join
        ) || writeln("-1 -1 -1")
    )(readln.split.to!(long[]));
}
