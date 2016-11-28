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
    int MOD = 26;
    int[] str = readln.chomp.map!(c => c-'a').array.to!(int[]);
    int K = readln.chomp.to!int;
    int i = 0;
    while(K > 0 && i<str.length) {
        while (i<str.length && str[i] == 0) i++;
        if (i>=str.length) break;
        if (MOD - str[i] <= K) {
            K -= MOD - str[i];
            str[i] = 0;
        }
        i++;
    }
    K %= MOD;
    str.back += K;

    str.map!(a => (a+'a').to!char).writeln;
}
