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

int N, M;
void main() {
    string[] input = readln.split;
    N = input[0].to!int;
    M = input[1].to!int;

    int a, b, c;
    bool flg = false;
    foreach(int i; 0..2) {
        if (M-2*N-i>=0 && 4*N-M-i>=0 && (M-2*N-i)%2==0) {
            a = (4*N-M-i)/2;
            b = i;
            c = (M-2*N-i)/2;
            flg = true;
        }
    }
    flg ? writefln("%d %d %d", a, b, c):writeln("-1 -1 -1");
}
