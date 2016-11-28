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

void main() {
    int N, D, X, Y;
    readf("%d %d\n", &N, &D);
    readf("%d %d\n", &X, &Y);

    if (X%D!=0 || Y%D!=0) {
        writeln(0.0);
        return;
    }

    X /= D;
    Y /= D;

    double ans = 0;
    foreach(i; 0..N+1) {
        int j = N-i;
        if ((i+X)%2!=0 || (j+Y)%2!=0) continue;
        ans += comb(N, i)/2.0^^N*comb(i, (i+X)/2-X)/2.0^^N*comb(j, (j+Y)/2-Y);
    }
    writefln("%.9f", ans);
}

double comb(int n, int r) {
    if (r==0 || r==n) return 1;
    if (r<0 || n<r) return 0;
    return memoize!comb(n-1, r-1) + memoize!comb(n-1, r);
}
