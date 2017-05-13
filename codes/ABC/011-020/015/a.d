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
    string str1 = readln.chomp;
    string str2 = readln.chomp;
    writeln(str1.length>str2.length ? str1 : str2);
}
