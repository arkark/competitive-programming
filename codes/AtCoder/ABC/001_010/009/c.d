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
    int K = input[1];
    string str = readln.chomp;
    string sorted = str.dup.sort.to!string;
    int k = 0;
    N.iota.array.to!(int[]).map!((i) {
        string str1 = str[i+1..$];
        foreach(j, c; sorted) {
            string str2 = sorted[0..j] ~ sorted[j+1..$];
            int x = c==str[i] ? 0:1;
            if (N-i-1-reduce!"a+b"(0, str2.uniq.map!(a => min(str1.count(a), str2.count(a)).to!int))+k+x <= K) {
                sorted = str2;
                k += x;
                return c;
            }
        }
        return '_';
    }).writeln;
}
