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
    int N, M;
    readf("%d %d\n", &N, &M);

    long[][] ary = N.rep!(() => readln.split.to!(long[]));

    int s = 0;
    for(int i=0; i<N-1; i++) {
        for(int j=0; j<M; j++) {
            if (ary[i][j]<ary[i+1][j]) break;
            if (ary[i][j]==ary[i+1][j]) {
                if (j<N-1) continue;
            }
            f(ary[i+1]);
            j=-1;
            s++;
            if (s > 10000) {
                (-1).writeln;
                return;
            }
        }
    }
    s.writeln;
}

void f(long[] ary) {
    foreach(i; 0..ary.length-1) {
        ary[i+1] = ary[i]+ary[i+1];
    }
}
