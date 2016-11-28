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

void main() {
    int N = readln.chomp.to!int;
    int[6] ary;
    foreach(int i; 0..6) {
        ary[i] = (N/5+i)%6+1;
    }
    N %= 5;
    foreach(int i; 0..N) {
        swap(ary[i%5], ary[i%5+1]);
    }
    for(int i=0; i<ary.length; i++) {
        write(ary[i]);
    }
    writeln("");
}
