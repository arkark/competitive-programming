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
void times(alias pred)(int n) {
    foreach(i; 0..n) pred();
}
auto rep(alias pred, T = typeof(pred()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

long INF = long.max/3;

void main() {
    int N, M;
    readf("%d %d\n", &N, &M);

    Vertex[int][] vs = new Vertex[int][N];
    vs.front[1] = new Vertex(0, 1);
    M.times!({
        int a, b, c, t;
        readf("%d %d %d %d\n", &a, &b, &c, &t);
        a--; b--;
        if (c !in vs[a]) vs[a][c] = new Vertex(a, c);
        if (c !in vs[b]) vs[b][c] = new Vertex(b, c);
        vs[a][c].edges ~= Edge(vs[a][c], vs[b][c], t);
        vs[b][c].edges ~= Edge(vs[b][c], vs[a][c], t);
    });
    foreach(i; 0..N) {
        Vertex[] ary = vs[i].byValue.array.sort!((a, b) => a.color<b.color).array;
        Vertex v1 = null;
        foreach(v2; ary) {
            if (v1 !is null) {
                v1.edges ~= Edge(v1, v2, abs(v1.color - v2.color));
                v2.edges ~= Edge(v2, v1, abs(v1.color - v2.color));
            }
            v1 = v2;
        }
    }

    vs.front[1].dist = 0;
    auto rbtree = redBlackTree!"a.dist!=b.dist ? a.dist<b.dist : a.color!=b.color ? a.color<b.color : a.index<b.index"(vs.front[1]);
    while (!rbtree.empty) {
        Vertex v = rbtree.front;
        rbtree.removeFront;
        foreach(e; v.edges) {
            if (e.end.dist > e.start.dist + e.cost) {
                rbtree.removeKey(e.end);
                e.end.dist = e.start.dist + e.cost;
                rbtree.insert(e.end);
            }
        }
    }

    vs.back.byValue.map!(v => v.dist).reduce!min.writeln;
}

class Vertex {
    int index;
    int color;
    long dist;
    Edge[] edges;
    this(int index, int color) {
        this.index = index;
        this.color = color;
        this.dist = INF;
    }
    override string toString() const {return "";}
}

struct Edge {
    Vertex start, end;
    long cost;
}
