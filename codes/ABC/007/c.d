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
    string[] input = readln.split;
    int R = input[0].to!int;
    int C = input[1].to!int;
    int[2] s = readln.split.to!(int[]).map!(a=>a-1).array;
    int[2] g = readln.split.to!(int[]).map!(a=>a-1).array;
    int[int[2]] grid;
    const int INF = 1<<30;
    foreach(int i; 0..R) {
        string str = readln;
        foreach(int j; 0..C) {
            grid[[i, j]] = str[j] == '.' ? INF:-1;
        }
    }
    grid[s] = 0;
    auto list = DList!(int[2])([s]);
    int[] vx = [1, 0, -1,  0];
    int[] vy = [0, 1,  0, -1];
    while (!list.empty) {
        int[2] p = list.front;
        list.removeFront;
        foreach(int i; 0..4) {
            if (p[0]>=vx[i] && p[0]<R+vx[i] && p[1]>=vy[i] && p[1]<C+vy[i] && grid[[p[0]-vx[i], p[1]-vy[i]]] == INF) {
                list.insert!(int[2])([p[0]-vx[i], p[1]-vy[i]]);
                grid[[p[0]-vx[i], p[1]-vy[i]]] = grid[p]+1;
            }
        }
    }
    grid[g].writeln;
}
