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
    int N, A, B;
    readf("%d %d %d\n", &N, &A, &B);
    string str = readln.chomp;
    int x, y;
    foreach(i, c; str) {
        if (c=='a') {
            writeln(x+y<A+B ? "Yes":"No");
            x++;
        } else if (c=='b') {
            writeln(x+y<A+B && y<B ? "Yes":"No");
            if (x+y<A+B && y<B) y++;
        } else {
            writeln("No");
        }
    }
}
