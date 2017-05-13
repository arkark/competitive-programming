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
    readln.chomp.to!int.iota.map!(_=>readln.chomp.to!int).array.sort.uniq.array.reverse.drop(1).front.writeln;
}
