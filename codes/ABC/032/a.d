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
    int a = readln.chomp.to!int;
    int b = readln.chomp.to!int;
    int n = readln.chomp.to!int;
    while(true) {
        if (n%a==0 && n%b==0) {
            n.writeln;
            break;
        }
        n++;
    }
}
