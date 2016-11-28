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
    string[] input = readln.split;
    int N = input[0].to!int;
    int Q = input[1].to!int;
    string ans = "kogakubu10gokan";
    foreach(i; 0..N) {
        input = readln.split;
        if (input[0].to!int <= Q) ans = input[1];
    }
    ans.writeln;
}
