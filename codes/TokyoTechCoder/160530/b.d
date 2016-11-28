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

void main() {
    int N = readln.chomp.to!int;
    foreach(i; 0..N) {
        int k, p;
        readf("%d %d\n", &k, &p);
        writeln(k%p==0 ? p:k%p);
    }
}
