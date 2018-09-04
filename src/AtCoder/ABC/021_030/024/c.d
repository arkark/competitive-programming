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
    int N, D, K;
    readf("%d %d %d\n", &N, &D, &K);
    int[][] ary = D.rep(()=>readln.split.to!(int[]).map!"a-1".array);
    K.times({
        (){
            int s, t;
            readf("%d %d\n", &s, &t);
            s--; t--;
            foreach(i, lr; ary) {
                if (s<lr[0] || lr[1]<s) continue;
                if (s<t) {
                    s = min(t, lr[1]);
                } else {
                    s = max(t, lr[0]);
                }
                if (s==t) return i+1;
            }
            return 0;
        }().writeln;
    });
}
