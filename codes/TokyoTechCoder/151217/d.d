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
    int INF = 1<<30;
    int[] vx = [-1, 0, 1, 0];
    int[] vy = [0, 1, 0, -1];
    while(true) {
        int[] input = readln.split.to!(int[]);
        if (input == [0, 0]) break;
        int w = input[0];
        int h = input[1];

        bool[][][] passable = new bool[][][](w, h, 4);
        foreach(int i; 0..2*h-1) {
            input = readln.split.to!(int[]);
            if (i%2 == 0) {
                for(int j=0; j<input.length; j++) {
                    if (input[j] == 0) {
                        passable[j][i/2][2] = true;
                        passable[j+1][i/2][0] = true;
                    }
                }
            } else {
                for(int j=0; j<input.length; j++) {
                    if (input[j] == 0) {
                        passable[j][i/2][1] = true;
                        passable[j][i/2+1][3] = true;
                    }
                }
            }
        }

        int[][] ary = new int[][](w, h);
        foreach(int i; 0..w) ary[i][] = INF;
        ary[0][0] = 1;
        auto list = DList!(Point)(Point(0, 0));
        while (!list.empty) {
            Point p = list.front;
            list.removeFront;
            for (int i=0; i<vx.length; i++) {
                if (passable[p.x][p.y][i] && ary[p.x+vx[i]][p.y+vy[i]] == INF) {
                    ary[p.x+vx[i]][p.y+vy[i]] = ary[p.x][p.y]+1;
                    list.insert(Point(p.x+vx[i], p.y+vy[i]));
                }
            }
        }
        writeln(ary[w-1][h-1] == INF ? 0:ary[w-1][h-1]);
    }
}
struct Point {
    int x, y;
    this(int x, int y) {
        this.x = x;
        this.y = y;
    }
}
