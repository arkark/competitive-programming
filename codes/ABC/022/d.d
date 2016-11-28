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

immutable double INF = 1e30;
int N;
void main() {
    N = readln.chomp.to!int;
    writefln("%.6f", 1.0/solve()*solve());
}

double solve() {
    Vector[] ary = N.rep({
        Vector v;
        readf("%f %f\n", &v.x, &v.y);
        return v;
    });
    Vector ave = ary.reduce!"a+b"/ary.length;
    return ary.map!(v => distSq(v, ave)).reduce!max.sqrt;
}

struct Vector {
    double x, y;
    Vector opBinary(string op)(Vector rhs) {
        mixin("return Vector(this.x"~op~"rhs.x, this.y"~op~"rhs.y);");
    }
    Vector opBinary(string op, T)(T rhs) {
        mixin("return Vector(this.x"~op~"rhs, this.y"~op~"rhs);");
    }
}

Vector mult(double a, Vector p) {
    return Vector(a*p.x, a*p.y);
}
double cross(Vector v1, Vector v2) {
    return v1.x*v2.y - v1.y*v2.x;
}
double dot(double z1, double z2) {
    return z1*z2;
}
double dot(Vector v1, Vector v2) {
    return v1.x*v2.x + v1.y*v2.y;
}
double distSq(Vector v1, Vector v2) {
    return (v2.x-v1.x)^^2 + (v2.y-v1.y)^^2;
}
double dist(Vector v1, Vector v2) {
    return sqrt(distSq(v1, v2));
}
