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
    Edge e1;
    readf("%f %f %f %f\n", &e1.p.x, &e1.p.y, &e1.q.x, &e1.q.y);
    int N = readln.chomp.to!int;
    Edge[] edges = new Edge[N];
    foreach(i; 0..N) {
        Vector v;
        readf("%f %f\n", &v.x, &v.y);
        edges[i].p = v;
        edges[(i+1)%$].q = v;
    }
    writeln(edges.count!(e2 => intersected(e1, e2))/2+1);
}

bool intersected(Edge e1, Edge e2) {
    return (e1.q-e1.p).cross(e2.p-e1.p).dot((e1.q-e1.p).cross(e2.q-e1.p)) < 0 && (e2.q-e2.p).cross(e1.p-e2.p).dot((e2.q-e2.p).cross(e1.q-e2.p)) < 0;
}

struct Vector {
    double x, y;
    Vector opBinary(string op)(Vector rhs) {
        mixin("return Vector(this.x"~op~"rhs.x, this.y"~op~"rhs.y);");
    }
}
struct Edge {
    Vector p, q;
}

Vector mult(double a, Vector p) {
    return Vector(a*p.x, a*p.y);
}
double cross(Vector p1, Vector p2) {
    return p1.x*p2.y - p1.y*p2.x;
}
double dot(double z1, double z2) {
    return z1*z2;
}
double dot(Vector p1, Vector p2) {
    return p1.x*p2.x + p1.y*p2.y;
}
double dist(Vector p1, Vector p2) {
    return sqrt((p2.x-p1.x)^^2 + (p2.y-p1.y)^^2);
}
