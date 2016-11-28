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
    int sum = 0;
    foreach(i; 0..10) sum += readln.chomp.to!int;
    sum.writeln; 
}
