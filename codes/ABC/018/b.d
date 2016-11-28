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
import std.datetime;

void main() {
    char[] str = readln.chomp.to!(char[]);
    int N = readln.chomp.to!int;
    foreach(i; 0..N) {
        int[] input = readln.split.to!(int[]).map!"a-1".array;
        reverse(str[input[0]..input[1]+1]);
    }
    str.writeln;
}
