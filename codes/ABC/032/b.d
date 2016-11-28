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
    string s = readln.chomp;
    int k = readln.chomp.to!int;
    string[] ary;
    foreach(i; 0..s.length.to!int-k+1) {
        ary ~= s[i..i+k];
    }
    ary.sort.uniq.array.length.writeln;
}
