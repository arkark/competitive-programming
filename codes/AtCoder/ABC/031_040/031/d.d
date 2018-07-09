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

int K, N;
string[] v, w;
void main() {
    string[] strs = readln.split;
    K = strs[0].to!int;
    N = strs[1].to!int;
    v = new string[N];
    w = new string[N];
    foreach(int i; 0..N) {
        strs = readln.split;
        v[i] = strs[0];
        w[i] = strs[1];
    }
    string[] ary = new string[K];
    int[] len = new int[K];
    for (int i=0; i<3^^K; i++) {
        for (int j=0; j<K; j++) {
            len[j] = i/3^^j%3+1;
        }
        if (func(0, ary, len)) break;
    }
}
bool func(int depth, string[] ary, int[] len) {
    if (depth == N) {
        for (int i=0; i<ary.length; i++) {
            ary[i].writeln();
        }
        return true;
    } else {
         string[] _ary = ary.dup;
         string s = w[depth].dup.to!string;
         bool flg = true;
         for (int j=0; j<v[depth].length; j++) {
             int x = len[(v[depth][j]-'0').to!int-1];
             if (s.length < x) {
                 flg = false;
                 break;
             }
             if (ary[(v[depth][j]-'0').to!int-1] != "") {
                 if (ary[(v[depth][j]-'0').to!int-1] != s.take(x).to!string) {
                     flg = false;
                     break;
                 }
             } else {
                _ary[(v[depth][j]-'0').to!int-1] = s.take(x).to!string;
             }
             s = s.drop(x);
         }
         if (flg && s.length == 0) {
             return func(depth+1, _ary, len);
         }
         return false;
    }
}
