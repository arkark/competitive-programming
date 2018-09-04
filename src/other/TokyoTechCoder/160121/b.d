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

int n, x, m;
int[] l, r, s;
int maximum = -1;
void main() {
    int[] input = readln.split.to!(int[]);
    n = input[0];
    x = input[1];
    m = input[2];
    l = new int[m];
    r = new int[m];
    s = new int[m];
    foreach(i; 0..m) {
        input = readln.split.to!(int[]);
        l[i] = input[0]-1;
        r[i] = input[1]-1;
        s[i] = input[2];
    }

    int[] ans = rec(0, new int[n]);
    if (ans.empty) {
        writeln(-1);
    } else {
        ans.to!string.split(",").reduce!"a~b"[1..$-1].writeln;
    }
}
int[] rec(int depth, int[] ary) {
    if (depth == n) {
        int sum = ary.sum;
        if (sum <= maximum) {
            return [];
        } else {
            foreach(i; 0..m) {
                if (ary[l[i]..r[i]+1].sum != s[i]) return [];
            }
            maximum = sum;
            return ary;
        }
    } else {
        int[] result = [];
        foreach(i; 0..x+1) {
            int[] _ary = ary.dup;
            _ary[depth] = i;
            int[] temp = rec(depth+1, _ary);
            if (!temp.empty) result = temp;
        }
        return result;
    }
}
