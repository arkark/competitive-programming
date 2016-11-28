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
    int N = readln.chomp.to!int;
    long[] a = readln.split.to!(long[]);
    auto list = DList!(long)(0);
    int ans = 0;
    foreach(i; 0..N) {
        while(list.back > a[i]) {
            list.removeBack;
        }
        if (list.back < a[i]) {
            ans++;
            list.insertBack(a[i]);
        }
    }
    ans.writeln;
}
