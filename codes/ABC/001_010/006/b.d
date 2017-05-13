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

void main() {
    int n = readln.chomp.to!int;
    int a1, a2, a3;
    int a;
    foreach(int i; 0..n) {
        switch(i) {
        case 0, 1:
            a = 0; break;
        case 2:
            a = 1; break;
        default:
            a = (a1+a2+a3)%10007;
        }
        a3 = a2; a2 = a1; a1 = a;
    }
    a.writeln;
}
