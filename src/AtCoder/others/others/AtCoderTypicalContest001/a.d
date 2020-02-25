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

int[] dx = [-1,0,1,0];
int[] dy = [0,1,0,-1];
struct Point{int y,x;}
void main() {
    int[] input = readln.split.to!(int[]);
    int H = input[0];
    int W = input[1];
    Point s, g;
    bool[][] grid = new bool[][](H, W);
    foreach(y; 0..H) {
        char[] str = readln.chomp.to!(char[]);
        int x;
        if ((x = str.countUntil('s').to!int) != -1) {
            s = Point(y, x);
        }
        if ((x = str.countUntil('g').to!int) != -1) {
            g = Point(y, x);
        }
        grid[y] = str.map!(s=> s!='#').array;
    }
    auto list = DList!Point(s);
    while(!list.empty) {
        Point p = list.front;
        list.removeFront;
        if (grid[p.y][p.x]) {
            grid[p.y][p.x] = false;
        } else {
            continue;
        }
        foreach(i; 0..dx.length) {
            if (0<=p.y+dy[i] && p.y+dy[i]<H && 0<=p.x+dx[i] && p.x+dx[i]<W) {
                if (grid[p.y+dy[i]][p.x+dx[i]]) {
                    list.insertBack(Point(p.y+dy[i], p.x+dx[i]));
                }
            }
        }
    }
    writeln(grid[g.y][g.x] ? "No":"Yes");
}
