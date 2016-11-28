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
    for(int i=0; i+1<str.length; i++) {
        if (i>=0 && str[i..i+2]=="ST") {
            str = str[0..i]~str[i+2..$];
            i -= 2;
        }
    }
    str.length.writeln;
}
