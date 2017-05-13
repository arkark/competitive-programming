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
    const int N = 4;
    string[N][N] input;
    foreach(int i; 0..N) {
        input[i] = readln.split;
    }
    foreach(int i; 0..N) {
        foreach(int j; 0..N) {
            write(input[N-i-1][N-j-1], j==N-1 ? "\n":" ");
        }
    }
}
