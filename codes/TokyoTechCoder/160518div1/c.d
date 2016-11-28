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

struct Pos{int x, y;}
void main() {
    int size = 8;
    int N = readln.chomp.to!int;
    foreach(i; 0..N) {
        writeln("Data "~(i+1).to!string~":");
        readln;

        int[][] grid = new int[][](size, size);
        foreach(j; 0..size) {
            grid[j] = readln.chomp.map!(a => a=='0' ? 0:1).array;
        }
        Pos s;
        s.x = readln.chomp.to!int-1;
        s.y = readln.chomp.to!int-1;
        grid[s.y][s.x] = 0;

        auto list = DList!Pos(s);
        int[] dx = [1,2,3,-1,-2,-3,0,0,0,0,0,0];
        int[] dy = [0,0,0,0,0,0,1,2,3,-1,-2,-3];
        while (!list.empty) {
            Pos p = list.front;
            list.removeFront;
            foreach(j; 0..dx.length) {
                Pos _p = Pos(p.x+dx[j], p.y+dy[j]);
                if (0<=_p.x && _p.x<size && 0<=_p.y && _p.y<size) {
                    if (grid[_p.y][_p.x] == 1) {
                        grid[_p.y][_p.x] = 0;
                        list.insertBack(_p);
                    }
                }
            }
        }
        grid.map!(a => reduce!((b,c)=>b~c.to!string)("", a)).each!writeln;
    }
}
