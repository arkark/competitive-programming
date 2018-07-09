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

char[] str;
void main() {
    int N = readln.chomp.to!int;
    str = readln.chomp.to!(char[]);
    int cnt = 0;
    foreach(i; 0..N) {
        char[] s = readln.chomp.to!(char[]);
        if (rec(0, 0, s, [])) cnt++;
    }
    cnt.writeln;
}
bool rec(int depth, int index, char[] s, int[] ary) {
    if (ary.length == str.length) {
        return true;
    } else if (depth<s.length){
        if (s[depth] == str[index]) {
            if (ary.length<2 || depth-ary[$-1]==ary[$-1]-ary[$-2]) {
                int[] _ary = ary.dup;
                if (rec(depth+1, index+1, s, _ary~depth)) return true;
            }
        }
        if (rec(depth+1, index, s, ary)) return true;
    }
    return false;
}
