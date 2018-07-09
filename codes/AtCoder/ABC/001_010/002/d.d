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

void main() {
    string[] strs = readln.split;
    int N = strs[0].to!int;
    int M = strs[1].to!int;
    int[][] data = new int[][M];
    foreach(int i; 0..M) {
        data[i] = array(map!(a => a.to!int-1)(readln.split));
    }
    int ans = 0;
    foreach(int i; 0..2^^N) {
        bool flg = true;
        int count = 0;
        foreach(int j; 0..N) {
            if ((i>>j&1) == 1) {
                count++;
                foreach(int k; j+1..N) {
                    if (((i>>k&1) == 1) && !data.canFind([j, k])) flg = false;
                }
            }
        }
        if (flg && count > ans) ans = count;
    }
    ans.writeln();
}
