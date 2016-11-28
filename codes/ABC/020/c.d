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

long INF = 1L<<60;
int[] dx = [1,0,-1,0];
int[] dy = [0,1,0,-1];
struct Pos{int y, x;}
void main() {
    int H, W, T;
    readf("%d %d %d\n", &H, &W, &T);
    Pos s, g;

    bool[][] grid = H.iota.map!((y){
        int x=0;
        return readln.chomp.map!((c) {
            if (c=='S') s = Pos(y, x);
            if (c=='G') g = Pos(y, x);
            x++;
            return c=='#';
        }).array;
    }).array;

    (l, r, bool delegate(int) pred) {
        // binary search
        while(l<r) {
            int c = (l+r)/2;
            if(pred(c)) {
                if (l==c) break;
                l = c;
            } else {
                r = c;
            }
        }
        return l;
    }(1, T+1, (t) {
        // dijkstra
        static long[][] dist;
        dist = H.iota.map!(_=>W.iota.map!(_=>INF).array).array;
        bool[][] visited = new bool[][](H, W);
        dist[s.y][s.x] = 0;
        auto rbtree = redBlackTree!((a, b) {
            if (dist[a.y][a.x]==dist[b.y][b.x]) return a.x==b.x ? a.y<b.y : a.x<b.x;
            return dist[a.y][a.x]<dist[b.y][b.x];
        })(s);
        while(!rbtree.empty) {
            Pos p = rbtree.front;
            if (p == g) break;
            visited[p.y][p.x] = true;
            rbtree.removeFront;
            foreach(_p; 4.iota.map!(i => Pos(p.y+dy[i], p.x+dx[i])).filter!(_p => 0<=_p.y && _p.y<H && 0<=_p.x && _p.x<W)) {
                if (visited[_p.y][_p.x]) continue;
                if (dist[p.y][p.x]+(grid[_p.y][_p.x] ? t:1) < dist[_p.y][_p.x]) {
                    rbtree.removeKey(_p);
                    dist[_p.y][_p.x] = dist[p.y][p.x]+(grid[_p.y][_p.x] ? t:1);
                    rbtree.insert(_p);
                }
            }
        }
        return dist[g.y][g.x]<=T;
    }).writeln;
}
