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

void times(int n, void delegate() pred) {
    foreach(i; 0..n) pred();
}
T[] rep(T)(int n, T delegate() pred) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

struct Pos{int y, x;}
void main() {
    int R, C, K, N;
    readf("%d %d %d\n%d\n", &R, &C, &K, &N);
    int[] row = new int[R];
    int[] col = new int[C];
    Pos[] candies = new Pos[N];
    foreach(i; 0..N) {
        int r, c;
        readf("%d %d\n", &r, &c);
        row[r-1]++;
        col[c-1]++;
        candies[i] = Pos(r-1, c-1);
    }

    long ans;

    long[] ary = new long[R+1];
    foreach(i; 0..R) {
        ary[row[i]]++;
    }
    foreach(i; 0..C) {
        if (col[i]<=K) ans += ary[K-col[i]];
    }

    foreach(i; 0..N) {
        if (row[candies[i].y]+col[candies[i].x]==K) ans--;
        if (row[candies[i].y]+col[candies[i].x]==K+1) ans++;
    }

    ans.writeln;
}
