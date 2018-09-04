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
    int N = 100;
    int[] input;
    input = readln.split.to!(int[]);
    Sphere red = Sphere(Point(input[0], input[1]), input[2]);
    input = readln.split.to!(int[]);
    Rectangle blue = Rectangle(Point(input[0], input[1]), Point(input[2], input[3]));
    double[][] ary = new double[][](2*N, 2*N);
    foreach(int i; 0..2*N) foreach(int j; 0..2*N) {
        ary[i][j] = 0;
    }
    foreach(int i; 0..2*N) foreach(int j; 0..2*N) {
        int x = i-N;
        int y = j-N;
        int count = 0;
        foreach(k; 0..4) {
            if ((x+dx[k]-red.c.x)^^2+(y+dy[k]-red.c.y)^^2 <= red.r^^2) count++;
        }
        if (count==4) {
            ary[i][j] += 1;
        } else if (count >= 2) {
            ary[i][j] += 0.5;
        }
        if (blue.p1.x<=x && x<blue.p2.x && blue.p1.y<=y && y<blue.p2.y) {
            ary[i][j] -= 1;
        }
    }
    bool flg1, flg2;
    foreach(int i; 0..2*N) foreach(int j; 0..2*N) {
        if (ary[i][j]>0) flg1 = true;
        if (ary[i][j]<0) flg2 = true;
    }
    writeln(flg1 ? "YES":"NO");
    writeln(flg2 ? "YES":"NO");
}
int[] dx = [0, 0, 1, 1];
int[] dy = [0, 1, 0, 1];
struct Point{int x, y;}
struct Sphere{Point c; int r;}
struct Rectangle{Point p1, p2;}
