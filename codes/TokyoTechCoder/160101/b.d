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

int N;
int tg, tw;
Vector[] vertices;
double[] ary1, ary2;
Vector start, target;
const double RATIO = (1.0 + sqrt(5.0)) / 2.0;
const double EPS = 1e-10;
void main() {
    while(true) {
        N = readln.chomp.to!int;
        if (N==0) break;
        vertices = new Vector[N];
        int[] input = readln.split.to!(int[]);
        foreach(i, ref e; vertices) e = Vector(input[2*i], input[2*i+1]);
        tg = readln.chomp.to!int;
        tw = readln.chomp.to!int;
        input = readln.split.to!(int[]);
        start = Vector(input[0], input[1]);
        input = readln.split.to!(int[]);
        target = Vector(input[0], input[1]);

        foreach(i; 0..vertices.length) {
            if (cross(start-vertices[i], vertices[(i+1)%$]-vertices[i]) == 0) {
                vertices = start~vertices[i+1..$]~vertices[0..i+1]~start;
                break;
            }
        }

        ary1 = new double[vertices.length];
        ary1[0] = 0;
        foreach(i; 1..ary1.length) {
            ary1[i] = ary1[i-1]+dist(vertices[i-1], vertices[i]);
        }
        ary2 = new double[vertices.length];
        ary2[$-1] = 0;
        foreach_reverse(i; 0..ary2.length-1) {
            ary2[i] = ary2[i+1]+dist(vertices[i+1], vertices[i]);
        }

        foreach(i; 0..vertices.length) {
            if (ary1[i]>=ary2[i]) {
                double ratio = (ary1[i]-ary2[i])/(ary1[i]-ary1[i-1])/2.0;
                Vector vec = vertices[i-1]*ratio+vertices[i]*(1-ratio);
                vertices = vertices[0..i]~vec~vertices[i..$];
                break;
            }
        }

        ary1 = new double[vertices.length];
        ary1[0] = 0;
        foreach(i; 1..ary1.length) {
            ary1[i] = ary1[i-1]+dist(vertices[i-1], vertices[i]);
        }
        ary2 = new double[vertices.length];
        ary2[$-1] = 0;
        foreach_reverse(i; 0..ary2.length-1) {
            ary2[i] = ary2[i+1]+dist(vertices[i+1], vertices[i]);
        }

        double ans = double.max;
        foreach(i; 0..vertices.length-1) {
            ans = min(ans, goldenSectionSearch(i));
        }
        writefln("%.12f", ans);
    }
}

double goldenSectionSearch(size_t i) {
    Vector a_p = vertices[i];
    Vector b_p = vertices[i+1];
    double a = func(i, a_p);
    double b = func(i, b_p);
    Vector c1_p = (a_p*RATIO+b_p)/(RATIO+1.0);
    Vector c2_p = (a_p+b_p*RATIO)/(RATIO+1.0);
    double c1 = func(i, c1_p);
    double c2 = func(i, c2_p);
    while(true) {
        if (abs(a-b) < EPS && dist(a_p, b_p) < EPS) {
            return c1;
        } else if (c1 < c2) {
            b_p = c2_p;
            b = c2;
            c2_p = c1_p;
            c2 = c1;
            c1_p = (a_p*RATIO+b_p)/(RATIO+1.0);
            c1 = func(i, c1_p);
        } else {
            a_p = c1_p;
            a = c1;
            c1_p = c2_p;
            c1 = c2;
            c2_p = (a_p+b_p*RATIO)/(RATIO+1.0);
            c2 = func(i, c2_p);
        }
    }
}

double func(size_t i, Vector v) {
    return min(ary1[i]+dist(vertices[i], v), ary2[i+1]+dist(vertices[i+1], v)) * tg + dist(v, target) * tw;
}

struct Vector {
    double x, y;
    this(double x, double y) {
        this.x = x;
        this.y = y;
    }
    Vector opBinary(string op)(Vector rhs) if (op == "+") {
        return Vector(this.x+rhs.x, this.y+rhs.y);
    }
    Vector opBinary(string op)(Vector rhs) if (op == "-") {
        return Vector(this.x-rhs.x, this.y-rhs.y);
    }
    Vector opBinary(string op, T)(T rhs) if (op == "*") {
        return Vector(this.x*rhs, this.y*rhs);
    }
    Vector opBinary(string op, T)(T rhs) if (op == "/") {
        return Vector(this.x/rhs, this.y/rhs);
    }
}
double dot(Vector v1, Vector v2) {
    return v1.x*v2.x + v1.y*v2.y;
}
double cross(Vector v1, Vector v2) {
    return v1.x*v2.y - v1.y*v2.x;
}
double size(Vector v) {
    return sqrt(v.x^^2 + v.y^^2);
}
double dist(Vector v1, Vector v2) {
    return size(v1-v2);
}
