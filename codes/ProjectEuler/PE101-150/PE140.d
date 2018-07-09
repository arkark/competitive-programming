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
import std.concurrency;
void times(alias fun)(int n) {
    foreach(i; 0..n) fun();
}
auto rep(alias fun, T = typeof(fun()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = fun();
    return res;
}

/*
  PE137と同じ要領で(5n+7)^2-5m^2 = 44
  これにLMM algorithmを適用して自然数解を小さい順に探索
*/

void main() {
    auto t = redBlackTree!(
        (a, b) => a[0]!=b[0] ? a[0]<b[0] : a[1]<b[1],
        false
    )([[7, 1], [43, 19], [17, 7], [13, 5], [8, 2], [32, 14]].to!(long[2][]));

    int N = 30;
    int i = 0;
    long[] ans = [];
    while(!t.empty && i<N) {
        long[2] a = t.front;
        t.removeFront;
        if (a[0]-7>0 && (a[0]-7)%5 == 0 && a[1]>0) {
            ans ~= (a[0]-7)/5;
            i++;
        }
        t.insert(a.mult);
    }
    ans.writeln;
    ans.sum.writeln;
}

long[2] mult(long[2] v) {
    static long[2][2] m = [[9, 20], [4, 9]];
    return [m[0][0]*v[0] + m[0][1]*v[1], m[1][0]*v[0] + m[1][1]*v[1]];
}
