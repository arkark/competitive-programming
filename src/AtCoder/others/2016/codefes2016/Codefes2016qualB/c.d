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

long INF = long.max/3;
void main() {
    int W, H;
    readf("%d %d\n", &W, &H);
    long[] ary1 = (W.rep!(() => readln.chomp.to!long)~INF).sort!((a, b) => a<b).array;
    long[] ary2 = (H.rep!(() => readln.chomp.to!long)~INF).sort!((a, b) => a<b).array;

    int i, j;
    long ans = 0;
    while(i+j<W+H) {
        if (ary1[i]<ary2[j]) {
            ans += ary1[i]*(H+1-j);
            i++;
        } else if (ary2[j]<ary1[i]) {
            ans += ary2[j]*(W+1-i);
            j++;
        } else {
            if (i<j) {
                ans += ary1[i]*(H+1-j);
                i++;
            } else {
                ans += ary2[j]*(W+1-i);
                j++;
            }
        }
    }
    ans.writeln;
}
