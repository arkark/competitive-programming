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
import std.datetime;

const double phi = (1+sqrt(5.0))/2;
double p;
void main() {
    p = readln.chomp.to!double;
    double l=0, r=1e2;
    double c1 = l*phi/(phi+1) + r*1/(phi+1);
    double c2 = l*1/(phi+1) + r*phi/(phi+1);
    double _c1 = func(c1);
    double _c2 = func(c2);
    foreach(_; 0..1000000) {
        if (_c1>_c2) {
            l = c1;
            c1 = c2;
            _c1 = _c2;
            c2 = l*1/(phi+1) + r*phi/(phi+1);
            _c2 = func(c2);
        } else {
            r = c2;
            c2 = c1;
            _c2 = _c1;
            c1 = l*phi/(phi+1) + r*1/(phi+1);
            _c1 = func(c1);
        }
    }
    writefln("%.8f", _c1);
}

double func(double x) {
    return x + p/2.0^^(x/1.5);
}
