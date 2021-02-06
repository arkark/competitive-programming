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
    int[] f(int i) {
        return N.iota.map!"a+1".map!((j) {
            if (i==j) return 0;
            writeln("? ", i, " ", j);
            stdout.flush();
            return readln.chomp.to!int;
        }).array;
    }
    writeln("! ", (i => f(i).reduce!max)((ary){
        int m = -1;
        int index = -1;
        foreach(int i, e; ary) {
            if (e>m) {
                m = e;
                index = i;
            }
        }
        return index;
    }(f(1))+1));
}
