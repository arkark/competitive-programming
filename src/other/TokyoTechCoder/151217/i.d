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

double INF = 1e10;
void main() {
    int MAX = 5;
    int[] input;
    while(true) {
        int n = readln.chomp.to!int;
        if (n == 0) break;

        Mirror[] mirrors = new Mirror[n];
        foreach(int i; 0..n) {
            input = readln.split.to!(int[]);
            mirrors[i] = Mirror(i, Point(input[0], input[1]), Point(input[2], input[3]));
        }

        input = readln.split.to!(int[]);
        Point goal = Point(input[0], input[1]);
        input = readln.split.to!(int[]);
        Point start  = Point(input[0], input[1]);

        double ans = INF;
        int[] ary = new int[MAX];
        for(ary[0]=-1; ary[0]<n; ary[0]++) for(ary[1]=-1; ary[1]<n; ary[1]++) for(ary[2]=-1; ary[2]<n; ary[2]++) for(ary[3]=-1; ary[3]<n; ary[3]++) for(ary[4]=-1; ary[4]<n; ary[4]++) {
            int[] _ary = ary.filter!(a=>a>=0).array;
            bool flg = true;
            for(int i=0; i<_ary.length.to!int-1; i++) {
                if (_ary[i]==_ary[i+1]) flg = false;
            }

            Point[] points = [start];
            for (int i=0; i<_ary.length; i++) {
                double d = dist(mirrors[_ary[i]].p, mirrors[_ary[i]].q);
                Point vec = Point((mirrors[_ary[i]].q.x-mirrors[_ary[i]].p.x)/d, (mirrors[_ary[i]].q.y-mirrors[_ary[i]].p.y)/d);
                double x = points.back.x;
                double y = points.back.y;
                x -= mirrors[_ary[i]].p.x;
                y -= mirrors[_ary[i]].p.y;
                double _x=x, _y=y;
                x = (-1+2*vec.x*vec.x)*_x + 2*vec.x*vec.y*_y;
                y = 2*vec.x*vec.y*_x + (-1+2*vec.y*vec.y)*_y;
                x += mirrors[_ary[i]].p.x;
                y += mirrors[_ary[i]].p.y;
                points ~= Point(x, y);
            }
            Point g = goal;
            double sum = 0;
            for(int i=points.length.to!int-1; i>=0; i--) {
                double d;
                if (points[i] == start) {
                    d = dist(start, g);
                } else {
                    d = getDistance(points[i], g, mirrors[_ary[i-1]]);
                }
                foreach(int j; 0..n) {
                    if (getDistance(points[i], g, mirrors[j]) < d && !(i>0 && j==_ary[i-1]) && !(i<_ary.length && j==_ary[i])) {
                        flg = false;
                    }
                }
                sum += d;
                if (i>0) g = getIntersection(points[i], g, mirrors[_ary[i-1]]);
            }
            if (flg && sum<ans) ans = sum;
        }
        writefln("%.4f", ans);
    }
}
double getDistance(Point p, Point q, Mirror mirror) {
    if (intersected(p, q, mirror)) {
        return dist(q, getIntersection(p, q, mirror));
    } else {
        return INF;
    }
}
Point getIntersection(Point p, Point q, Mirror mirror) {
    double d1 = abs(cross(p-mirror.p, mirror.q-mirror.p));
    double d2 = abs(cross(q-mirror.p, mirror.q-mirror.p));
    return p + mult(d1/(d1+d2), q-p);
}
bool intersected(Point p, Point q, Mirror mirror) {
    return (q-p).cross(mirror.p-p).dot((q-p).cross(mirror.q-p)) < 0 && (mirror.q-mirror.p).cross(p-mirror.p).dot((mirror.q-mirror.p).cross(q-mirror.p)) < 0;
}
struct Point {
    double x, y;
    this(double x, double y) {
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
struct Mirror {
    int id;
    Point p, q;
    this(int id, Point p, Point q) {
        this.id = id;
        this.p = p;
        this.q = q;
    }
}
Point mult(double a, Point p) {
    return Point(a*p.x, a*p.y);
}
double cross(Point p1, Point p2) {
    return p1.x*p2.y - p1.y*p2.x;
}
double dot(double z1, double z2) {
    return z1*z2;
}
double dot(Point p1, Point p2) {
    return p1.x*p2.x + p1.y*p2.y;
}
double dist(Point p1, Point p2) {
    return sqrt((p2.x-p1.x)^^2 + (p2.y-p1.y)^^2);
}
