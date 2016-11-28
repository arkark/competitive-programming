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
import std.ascii;

void main() {
    int N = readln.chomp.to!int;
    bool[][] m = N.iota.map!(_ => readln.chomp.map!(a => a=='1').array).array;
    writeln(m.bitDet ? "Odd":"Even");
}

// determinant of m (mod 2)
bool bitDet(in bool[][] m) in {
    assert(m.isSquare!bool);
} body {
    size_t N = m.length;
    bool[][] _m = N.iota.map!(i => m[i].dup).array;
    foreach(i; 0..N) {
        ptrdiff_t k = N.iota.countUntil!(j => j>=i && _m[j][i]);
        if (k==-1) return false;
        swap(_m[i], _m[k]);
        foreach(j; 0..N) {
            if (i==j) continue;
            if (!_m[j][i]) continue;
            _m[j][] ^= _m[i][];
        }
    }
    return true;
}

bool isRectanglar(T)(in T[][] m) {
    return m.all!(r => r.length == m[0].length);
}

bool isSquare(T)(in T[][] m) {
    return m.isRectanglar && m.length == m[0].length;
}
