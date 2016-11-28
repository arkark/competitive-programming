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

struct Pos{
    int r, c;
    Pos opBinary(string op)(Pos rhs) {
        mixin("return Pos(this.r" ~op~ "rhs.r, this.c" ~op~ "rhs.c);");
    }
}

int R, C, N;
int[Pos] aa;
void main() {
    readf("%d %d\n%d\n", &R, &C, &N);
    N.times!({
        int r, c, a;
        readf("%d %d %d\n", &r, &c, &a);
        r--; c--;
        aa[Pos(r, c)] = a;
    });

    writeln("Yes");

}
