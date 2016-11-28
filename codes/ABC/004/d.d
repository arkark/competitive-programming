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
    string[] input = readln.split;
    int R = input[0].to!int;
    int G = input[1].to!int;
    int B = input[2].to!int;

    int N = 300;
    int M = 100;
    long m = 1000000000000000L;
    for (int i=-N/2-N+M; i<=N/2+N-M; i++) {
        int leftG = i-G/2;
        int rightG = leftG+G-1;

        int rightR = min(-M+R/2, leftG-1);
        int leftR = rightR-R+1;
        int leftB = max(M-B/2, rightG+1);
        int rightB = leftB+B-1;

        long value = 0;
        value += sum(leftG, rightG, 0);
        value += sum(leftR, rightR, -M);
        value += sum(leftB, rightB, M);
        if (value < m) m = value;
    }
    m.writeln;
}
long sum(int x, int y, int z) {
    int left = x-z;
    int right = y-z;
    if (left > 0) return right*(right+1)/2 - left*(left-1)/2;
    if (right < 0) return (-left)*(-left+1)/2 - (-right)*(-right-1)/2;
    return right*(right+1)/2 + (-left)*(-left+1)/2;
}
