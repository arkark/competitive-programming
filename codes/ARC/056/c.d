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

void main() {
    int N; long K;
    readf("%d %d\n", &N, &K);
    //if (N>9) return; //

    long[][] w = N.rep(() => readln.split.to!(long[]));

    long rec(int depth, int[] ary, bool[] flg) {
        if (depth==N) {
            long s = 0;
            foreach(j; 0..N) foreach(k; 0..j) {
                if (ary[j] != ary[k]) s+=w[j][k];
            }
            return flg.count!"a"*K - s;
        } else {
            long res = 0;
            foreach(i; 0..depth+1) {
                bool[] _flg = flg.dup;
                ary[depth] = i;
                _flg[i] = true;
                res = max(res, rec(depth+1, ary, _flg));
            }
            return res;
        }
    }

    rec(0, new int[N], new bool[N]).writeln;
}
