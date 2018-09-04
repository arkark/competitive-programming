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
import std.complex;
void times(alias pred)(int n) {
    foreach(i; 0..n) pred();
}
auto rep(alias pred, T = typeof(pred()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

void main() {
    int N = readln.chomp.to!int;
    int M = {
        int i = 1;
        while(i < 2*N) i<<=1;
        return i;
    }();

    Complex!double[] a = M.rep!(() => complex(0.0));
    Complex!double[] b = M.rep!(() => complex(0.0));
    foreach(i; 0..N) {
        int _a, _b;
        readf("%d %d\n", &_a, &_b);
        a[i] = complex(_a);
        b[i] = complex(_b);
    }

    foreach(e; 0~convolute(a, b).map!(a => a.re.round).array[0..2*N-1]) {
        e.writeln;
    }
}

Complex!double[] convolute(Complex!double[] x, Complex!double[] y) {
    int N = x.length.to!int;
    Complex!double[] _x = new Complex!double[N];
    Complex!double[] _y = new Complex!double[N];
    fft(x, _x);
    fft(y, _y);
    Complex!double[] _z = zip(_x, _y).map!"a[0]*a[1]".array;
    return inverseFft(_z);
}
