import std.stdio : readln, writeln;
import std.conv : to;
import std.string : chomp;
import std.range : iota;
import std.algorithm : map, count, cartesianProduct;
import std.functional : pipe;

void main() {
    (() => 0.iota(readln.chomp.to!long + 1)).pipe!(
        f => cartesianProduct(f(), f(), f())
    ).map!(
        as => 500*as[0] + 100*as[1] + 50*as[2]
    ).count(readln.chomp.to!long).writeln;
}
