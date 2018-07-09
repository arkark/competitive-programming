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
import std.ascii;
void times(alias pred)(int n) {
    foreach(i; 0..n) pred();
}
auto rep(alias pred, T = typeof(pred()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

int K;
string str;
void main() {
    K = readln.chomp.to!int;
    str = readln.chomp;
    if (str.length >16) return;

    int res = str.to!int;
    int[] ary = new int[K];
    rec(0, new int[K]).writeln;
}

int INF = int.max;
int rec(int depth, int[] ary) {
    if (depth==K) {
        int res = 0;
        foreach(i; 0..K-1) {
            str.writeln;
            ary[i].writeln;
            ary[i+1].writeln;
            if (ary[i+1]-ary[i]==0) continue;
            res = max(res, str[ary[i]..ary[i+1]].to!int);
        }
        return res==0 ? INF : res;
    } else {
        int minI = 0;
        if (depth >0) {
            minI = ary[depth-1];
        }

        int res = INF;
        foreach(i; minI..str.length+1) {
            ary[depth] = i;
            res = min(res, rec(depth+1, ary));
        }
        return res;
    }
}
