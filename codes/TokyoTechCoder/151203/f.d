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
    int Q = readln.chomp.to!int;
    foreach(int i; 0..Q) {
        int[] input = readln.split.to!(int[]);
        int c = input[0];
        int b = input[1];
        int n = input[2];
        int N = 0;
        for (; n>0; n--) {
            if (c>0 && b>0) {
                N++;
                c--;
                b--;
            } else {
                break;
            }
        }
        for (; b>0; b--) {
            if (c>1) {
                N++;
                c-=2;
            }
        }
        N += c/3;
        N.writeln;
    }
}
