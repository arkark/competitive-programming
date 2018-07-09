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

long INF = 10^^10;
void main() {
    string[] input = readln.split;
    int W = input[0].to!int;
    int H = input[1].to!int;
    long[][] grid = new long[][](W, H);
    foreach(int i; 0..W) grid[i][] = 1;
    Point s, g;
    Point[] m;
    int[] vx = [ 1, 0,-1, 0];
    int[] vy = [ 0, 1, 0,-1];
    int[] vx1 = [ 1, 1, 0,-1,-1,-1, 0, 1];
    int[] vy1 = [ 0, 1, 1, 1, 0,-1,-1,-1];
    int[] vx2 = [ 2, 2, 2, 1, 0,-1,-2,-2,-2,-2,-2,-1, 0, 1, 2, 2];
    int[] vy2 = [ 0, 1, 2, 2, 2, 2, 2, 1, 0,-1,-2,-2,-2,-2,-2,-1];
    foreach(int y; 0..H) {
        string str = readln.chomp;
        foreach(int x; 0..W) {
            switch(str[x]) {
            case 'S': s = Point(x, y); break;
            case 'G': g = Point(x, y); break;
            case 'M': m ~= Point(x, y); break;
            case '#':
                grid[x][y] = INF;
                for(int i=0; i<vx1.length; i++) {
                    if (x+vx1[i]>=0 && x+vx1[i]<W && y+vy1[i]>=0 && y+vy1[i]<H) {
                        grid[x+vx1[i]][y+vy1[i]] = max(3, grid[x+vx1[i]][y+vy1[i]]);
                    }
                }
                for(int i=0; i<vx2.length; i++) {
                    if (x+vx2[i]>=0 && x+vx2[i]<W && y+vy2[i]>=0 && y+vy2[i]<H) {
                        grid[x+vx2[i]][y+vy2[i]] = max(2, grid[x+vx2[i]][y+vy2[i]]);
                    }
                }
                break;
            default:
            }
        }
    }
    Point[] points = s~m~g;

    long[][] dist = new long[][](points.length, points.length);
    for (int i=0; i<points.length; i++) {
        Node[][] nodes = new Node[][](W, H);
        foreach(int x; 0..W) foreach(int y; 0..H) {
            nodes[x][y] = new Node(x, y, grid[x][y]);
        }
        nodes[points[i].x][points[i].y].value = 0;
        nodes[points[i].x][points[i].y].contain = true;
        Node[] _ary = [nodes[points[i].x][points[i].y]];
        _ary.length = nodes.join.length;
        auto queue = heapify!("a.value > b.value")(_ary, 1);
        while(!queue.empty) {
            Node doneNode = queue.front;
            queue.removeFront;
            doneNode.done = true;
            for (int j=0; j<vx.length; j++) {
                if (doneNode.x+vx[j]>=0 && doneNode.x+vx[j]<W && doneNode.y+vy[j]>=0 && doneNode.y+vy[j]<H) {
                    Node node = nodes[doneNode.x+vx[j]][doneNode.y+vy[j]];
                    node.value = min(node.value, doneNode.value+doneNode.cost);
                    if (!node.contain) {
                        queue.insert(node);
                        node.contain = true;
                    }
                }
            }
        }

        for (int j=0; j<points.length; j++) {
            dist[i][j] = nodes[points[j].x][points[j].y].value;
        }
    }

    long min = INF;
    auto ary = m.length.iota.map!(a=>a+1).array;
    do {
        auto _ary = 0~ary~(ary.length+1);
        long sum = 0;
        for (int i=1; i<_ary.length; i++) {
            sum += dist[_ary[i-1]][_ary[i]];
        }
        if (sum<min) min = sum;
    } while(nextPermutation(ary));
    min.writeln;
}
struct Point{
    int x, y;
    this(int x, int y) {
        this.x = x; this.y = y;
    }
}
class Node{
    long cost;
    bool done = false;
    bool contain = false;
    long value;
    int x, y;
    this(int x, int y, long cost) {
        this.x = x;
        this.y = y;
        this.cost = cost;
        this.value = INF;
    }
}
