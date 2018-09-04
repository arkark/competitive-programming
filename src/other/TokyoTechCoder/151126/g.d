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
    int N = readln.chomp.to!int;
    Point[][] points = new Point[][](N, 2);
    foreach(int i; 0..N) {
        int[] input = readln.split.to!(int[]);
        points[i] = [Point(input[0], input[1]), Point(input[2], input[3])];
        sort!((a,b) => a.x<b.x)(points[i]);
    }
    if (N > 101^^2/2) {
        writeln(0);
        return;
    }
    double ans = double.max;
    sort!((a, b) => a[0].x<b[0].x)(points);
    foreach(int i; 0..N) foreach(int j; i+1..N) {
        if (points[j][0].x - points[i][1].x > ans) continue;
        double value = getDistance(points[i], points[j]);
        if (value < ans) ans = value;
    }
    writefln("%.5f", ans);
}
double getDistance(Point[] p, Point[] q) {
    if ((p[1]-p[0]).cross(q[0]-p[0]).dot((p[1]-p[0]).cross(q[1]-p[0])) < 0 && (q[1]-q[0]).cross(p[0]-q[0]).dot((q[1]-q[0]).cross(p[1]-q[0])) < 0) {
        return 0;
    }

    double result = double.max;
    foreach(int i; 0..2) {
        double value1, value2;
        if ((q[i]-p[0]).dot(p[1]-p[0]) <= 0) {
            value1 = dist(p[0], q[i]);
        } else if ((q[i]-p[0]).dot(p[1]-p[0]) >= (p[1]-p[0]).dot(p[1]-p[0])) {
            value1 = dist(p[1], q[i]);
        } else {
            value1 = (p[0]-q[i]).cross(p[1]-p[0]).abs/dist(p[1], p[0]);
        }
        if ((p[i]-q[0]).dot(q[1]-q[0]) <= 0) {
            value2 = dist(q[0], p[i]);
        } else if ((p[i]-q[0]).dot(q[1]-q[0]) >= (q[1]-q[0]).dot(q[1]-q[0])) {
            value2 = dist(q[1], p[i]);
        } else {
            value2 = (q[0]-p[i]).cross(q[1]-q[0]).abs/dist(q[1], q[0]);
        }
        result = min(result, value1, value2);
    }
    return result;
}
int cross(Point p1, Point p2) {
    return p1.x*p2.y - p1.y*p2.x;
}
int dot(int z1, int z2) {
    return z1*z2;
}
int dot(Point p1, Point p2) {
    return p1.x*p2.x + p1.y*p2.y;
}
double dist(Point p1, Point p2) {
    return sqrt(((p2.x-p1.x)^^2 + (p2.y-p1.y)^^2).to!double);
}
struct Point{
    int x, y;
    this(int x, int y) {
        this.x = x;
        this.y = y;
    }
    Point opBinary(string op)(Point rhs) if (op == "+") {
        return Point(this.x+rhs.x, this.y+rhs.y);
    }
    Point opBinary(string op)(Point rhs) if (op == "-") {
        return Point(this.x-rhs.x, this.y-rhs.y);
    }
}
