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
    int[] input = readln.split.to!(int[]);
    int N = input[0];
    int M = input[1];
    int[] A = new int[N];
    int[] count = new int[N];
    foreach(int i; 0..N) {
        A[i] = readln.chomp.to!int;
    }
    foreach(int i; 0..M) {
        int B = readln.chomp.to!int;
        foreach(int j; 0..N) {
            if (A[j] <= B) {
                count[j]++;
                break;
            }
        }
    }
    int[] index = N.iota.map!(a=>a+1).array;
    sort!("a[0]>b[0]")(zip(count, index));
    index[0].writeln;
}
