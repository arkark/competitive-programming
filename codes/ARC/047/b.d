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

int N;
int[] x;
int[] y;
void main() {
    N = readln.chomp.to!int;
    x = new int[N];
    y = new int[N];
    int[] _x = new int[N];
    int[] _y = new int[N];
    foreach(i; 0..N) {
        int[] input = readln.split.to!(int[]);
        x[i] = input[0];
        y[i] = input[1];
        _x[i] = input[0]+input[1];
        _y[i] = input[0]-input[1];
    }
    int minX = _x.reduce!min;
    int maxX = _x.reduce!max;
    int minY = _y.reduce!min;
    int maxY = _y.reduce!max;
    int d = max(maxX-minX, maxY-minY)/2;
    check(minX+d, minY+d) || check(minX+d, maxY-d) || check(maxX-d, minY+d) || check(maxX-d, maxY-d);
}

bool check(int _px, int _py) {
    int px = (_px+_py)/2;
    int py = (_px-_py)/2;
    int d = dist(x[0], y[0], px, py);
    foreach(i; 1..N) {
        if (dist(x[i], y[i], px, py) != d) return false;
    }
    writeln(px, " ", py);
    return true;
}
int dist(int x1, int y1, int x2, int y2) {
    return abs(x1-x2)+abs(y1-y2);
}
