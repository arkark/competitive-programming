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
    while(true) {
        string str = readln.chomp;
        if (str == "END OF INPUT") break;
        str.split(" ").map!(s => s.length.to!string).reduce!"a~b".writeln;
    }
}
