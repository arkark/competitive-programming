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
    int H, W;
    readf("%d %d\n", &H, &W);

    H.rep!(() => readln.chomp.map!(c => c=='#').array).repeat.take(2).enumerate.each!((a) {
        H.iota.map!(i => W.iota.map!(j =>
            j==0   ? a.index==0 :
            j==W-1 ? a.index==1 :
            (i%2==a.index || a.value[i][j])
        ).map!(b => b ? '#':'.').to!string).each!writeln;
        if (a.index==0) writeln();
    });
}
