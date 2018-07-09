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

long MOD = 10L^^9 + 7;
void main() {
    int N = readln.chomp.to!int;
    long[] aryT = readln.split.to!(long[]);
    long[] aryA = readln.split.to!(long[]);
    if (aryT.back != aryA.front) {
        writeln(0);
    } else {
        long[] maxH = N.iota.map!(i => min(aryT[i], aryA[i])).array;
        long[] minH = N.rep!(() => 1L);
        foreach(i; 0..N) {
            if (i==0 || aryT[i]>aryT[i-1]) minH[i] = aryT[i];
            auto j = N-i-1;
            if (i==0 || aryA[j]>aryA[j+1]) minH[j] = aryA[j];
        }
        long[] po = N.iota.map!(i => maxH[i]-minH[i]+1).array;
        if (po.canFind!(a => a<=0)) {
            writeln(0);
        } else {
            1L.reduce!((a, b) => a*b%MOD)(po).writeln;
        }
    }
}
