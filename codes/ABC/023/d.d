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
void times(void delegate() pred)(int n) {
    foreach(i; 0..n) pred();
}
T[] rep(T)(int n, T delegate() pred) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

void main() {
    int N = readln.chomp.to!int;
    long[][] balloons = N.rep(() => readln.split.to!(long[]));

    ((l, r, bool delegate(long) pred) {
        // binary search
        while(l<r) {
            long c = (l+r)/2;
            if(pred(c)) {
                r = c;
            } else {
                if (l==c) break;
                l = c;
            }
        }
        return l;
    }(0L, balloons.map!(a=>a[0]).reduce!max + N * balloons.map!(a=>a[1]).reduce!max, (maxH) {
        long[] ary = new long[N];
        foreach(i; 0..N) {
            if (maxH<balloons[i][0]) return false;
            ary[cast(size_t) min(N-1, (maxH-balloons[i][0])/balloons[i][1])]++;
        }
        long s = 0;
        foreach(i; 0..N) {
            s+=ary[i];
            if (s>i+1) return false;
        }
        return true;
    })+1).writeln;
}
