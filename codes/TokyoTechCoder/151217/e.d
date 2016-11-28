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

void main() {
    int maxN = 10^^6;
    int[] f, f_odd;
    for(int n=1; ;n++) {
        f ~= func(n);
        if (f.back > maxN) break;
        if (f.back%2!=0) f_odd~= f.back;
    }
    int INF = 1<<30;

    int[] ary = new int[maxN+1];
    ary[] = INF;
    ary[0] = 0;
    foreach(int i; 0..maxN) {
        for(int n=0; n<f.length; n++) {
            if (i+f[n]<=maxN) {
                ary[i+f[n]] = min(ary[i+f[n]], ary[i]+1);
            } else {
                break;
            }
        }
    }
    int[] _ary = new int[maxN+1];
    _ary[] = INF;
    _ary[0] = 0;
    foreach(int i; 0..maxN) {
        for(int n=0; n<f_odd.length; n++) {
            if (i+f_odd[n]<=maxN) {
                _ary[i+f_odd[n]] = min(_ary[i+f_odd[n]], _ary[i]+1);
            } else {
                break;
            }
        }
    }

    while(true) {
        int N = readln.chomp.to!int;
        if (N==0) break;
        writeln(ary[N], " ", _ary[N]);
    }
}
int func(int n) {
    return n*(n+1)*(n+2)/6;
}
