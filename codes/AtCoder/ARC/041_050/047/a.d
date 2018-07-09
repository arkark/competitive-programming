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
    string S = readln.chomp;
    int num = 1;
    int ans = 0;
    foreach(s; S) {
        switch(s) {
            case '+':{
                num++;
                if (num > input[1]) {
                    num = 1;
                    ans++;
                }
            } break;
            default: {
                num--;
            }
        }
    }
    ans.writeln;
}
