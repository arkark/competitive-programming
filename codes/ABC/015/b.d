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
    int N = readln.chomp.to!int;
    int[] ary = readln.split.to!(int[]).filter!"a>0".array;
    writeln((ary.reduce!"a+b"+ary.length-1)/ary.length);
}
