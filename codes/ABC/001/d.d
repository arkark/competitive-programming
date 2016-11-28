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
    int N = readln.chomp.to!int;
    int[] ary = new int[2400/5+1];
    foreach(int i; 0..N) {
        string[] strs = readln.chomp.split("-");
        int s = strs[0].to!int;
        int e = strs[1].to!int;
        ary[s/5]++;
        if (e%5 == 0) e--;
        ary[(e/5+1)*5%100>=60 ? e/5+1+8:e/5+1]--;
    }
    bool flg = true;
    string str;
    for (int i=0; i<ary.length; i++) {
        if (i > 0) ary[i] += ary[i-1];
        if (flg && ary[i] > 0) {
            string s = to!string(i*5);
            while (s.length < 4) s = "0"~s;
            str = s~"-";
            flg = false;
        } else if (!flg && ary[i]==0){
            string s = to!string(i*5);
            while (s.length < 4) s = "0"~s;
            str ~= s;
            str.writeln();
            flg = true;
        }
    }
}
