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
import std.concurrency;

struct Point{int x,y;}
void main() {
    const int INF = 1<<30;
    int[] input = readln.split.to!(int[]);
    int R = input[0];
    int C = input[1];
    input = readln.split.to!(int[]).map!"a-1".array;
    Point s = Point(input[0], input[1]);
    input = readln.split.to!(int[]).map!"a-1".array;
    Point g = Point(input[0], input[1]);
    int[][] grid = null.repeat(R).map!(i => readln.chomp.map!(c => c=='#' ? INF:1).array).array;
    int[][] dist = INF.repeat(R).map!(e => e.repeat(C).array.to!(int[])).array;
    dist.writeln;
    /*auto list = DList!Point(s);*/
    /*int[] vx = [1, 0, -1,  0];
    int[] vy = [0, 1,  0, -1];
    while (!list.empty) {
        int[2] p = list.front;
        list.removeFront;
        foreach(int i; 0..4) {
            if (p[0]>=vx[i] && p[0]<R+vx[i] && p[1]>=vy[i] && p[1]<C+vy[i] && grid[[p[0]-vx[i], p[1]-vy[i]]] == INF) {
                list.insert!(int[2])([p[0]-vx[i], p[1]-vy[i]]);
                grid[[p[0]-vx[i], p[1]-vy[i]]] = grid[p]+1;
            }
        }*/
}
