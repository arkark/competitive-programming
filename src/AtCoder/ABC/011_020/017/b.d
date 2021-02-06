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
    string[] choku = ["ch", "o", "k", "u"];
    string str = readln.chomp;
    size_t i, j = str.length;
    while(i!=j) {
        i = j;
        foreach(e; choku) {
            if (str.endsWith(e)) str = str[0..$-e.length];
        }
        j = str.length;
    }
    writeln(str.empty ? "YES":"NO");
}
