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
    int[] input = readln.split.to!(int[]);
    int N = input[0];
    int K = input[1];
    int[] ary = N.iota.map!"a+1".array;
    int x = 1;
    foreach(i; 0..N) {
        int index = (x*(N-i)-1)/K;
        writeln(ary[index]);
        if (index<N-i-1) foreach(j; index..N-i-1) ary[j]=ary[j+1];
        x = (x*(N-i)-1)%K+1;
    }
}
