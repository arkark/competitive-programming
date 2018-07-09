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

void main() {
    string str = readln.chomp;

    long ans = 0;
    foreach(i; 0..2^^(str.length-1)) {
        size_t k = 0;
        foreach(j; 0..str.length-1) {
            if (i>>j&1) {
                ans += str[k..j+1].to!long;
                k = j+1;
            }
        }
        ans += str[k..$].to!long;
    }
    ans.writeln;
}
