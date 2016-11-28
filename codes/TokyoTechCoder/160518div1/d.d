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

struct Pos{int y, x;}
int[] dx = [1,0,-1,0];
int[] dy = [0,1,0,-1];
void main() {
    int[] input = readln.split.to!(int[]);
    int H = input[0];
    int W = input[1];
    int N = input[2];

    int[][] grid = new int[][](H, W);
    Pos[] ary = new Pos[N+1];
    foreach(i; 0..H) {
        grid[i] = readln.chomp.enumerate.tee!((a) {
            if (a[1]=='S') ary[0] = Pos(i, a[0].to!int);
            if (a[1].isDigit) ary[a[1]-'0'] = Pos(i, a[0].to!int);
        }).map!(a => a[1]).map!(a => a=='X' ? -1:1).array;
    }

    int[] ans = new int[N];

    foreach(i; 0..N) {
        auto list = DList!Pos(ary[i]);
        bool[][] flag = new bool[][](H, W);
        flag[ary[i].y][ary[i].x] = true;
        int[][] dist = new int[][](H, W);
        while (!list.empty) {
            Pos p = list.front;
            if (p == ary[i+1]) {
                ans[i] = dist[p.y][p.x];
                break;
            }
            list.removeFront;
            foreach(j; 0..4) {
                Pos _p = Pos(p.y+dy[j], p.x+dx[j]);
                if (0<=_p.y && _p.y<H && 0<=_p.x && _p.x<W) {
                    if (!flag[_p.y][_p.x] && grid[_p.y][_p.x]!=-1) {
                        dist[_p.y][_p.x] = dist[p.y][p.x]+1;
                        list.insertBack(_p);
                        flag[_p.y][_p.x] = true;
                    }
                }
            }
        }
    }
    ans.reduce!"a+b".writeln;
}
