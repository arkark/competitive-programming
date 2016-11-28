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
    Vector[] vectors = new Vector[N];
    foreach(i; 0..N) {
        vectors[i] = Vector(readln.split.to!(int[]));
    }

    long[] ans = new long[3];
    double EPS = 1e-10;
    foreach(i, v; vectors) {
        double[] ary = (vectors[0..i]~vectors[i+1..$]).map!(_v => atan2((_v-v).y.to!double, (_v-v).x.to!double)).array.sort;
        ary ~= ary.front+PI*2;
        int l = 0;
        foreach(r; 1..N) {
            while(l<r && ary[r]-ary[l]>PI/2-EPS) {
                if (abs(ary[r]-ary[l]-PI/2) < EPS || abs(ary[r]-ary[l]-PI*3/2) < EPS) {
                    ans[1]++;
                } else if (ary[r]-ary[l]<PI*3/2+EPS) {
                    ans[2]++;
                }
                l++;
            }
        }
    }
    ans[0] = N*(N-1)*(N-2)/6-ans[1]-ans[2];
    ans.to!(string[]).reduce!((a, b) => a~" "~b).writeln;
}

struct Vector {
    int x, y;
    this(int[] r) {
        this(r[0], r[1]);
    }
    this(int x, int y) {
        this.x = x;
        this.y = y;
    }
    Vector opBinary(string op)(Vector rhs) {
        mixin("return Vector(this.x"~op~"rhs.x, this.y"~op~"rhs.y);");
    }
}
int dot(Vector v1, Vector v2) {
    return v1.x*v2.x + v1.y*v2.y;
}
int cross(Vector v1, Vector v2) {
    return v1.x*v2.y - v1.y*v2.x;
}
double size(Vector v) {
    return sqrt((v.x^^2 + v.y^^2).to!double);
}
double dist(Vector v1, Vector v2) {
    return size(v1-v2);
}
