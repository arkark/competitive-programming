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

void times(int n, void delegate() pred) {
    foreach(i; 0..n) pred();
}
T[] rep(T)(int n, T delegate() pred) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

immutable long INF = 1L<<60;
void main() {
    int N, M;
    readf("%d %d\n", &N, &M);
    Vertex[] vertices = N.iota.map!(i => new Vertex(i)).array;
    M.times({
        int u, v; long l;
        readf("%d %d %d\n", &u, &v, &l);
        u--; v--;
        vertices[u].edges ~= Edge(vertices[u], vertices[v], l);
        vertices[v].edges ~= Edge(vertices[v], vertices[u], l);
    });

    vertices.front.cost = 0;
    int type = 0;
    auto rbtree = redBlackTree!"a.cost==b.cost ? a.index<b.index : a.cost<b.cost"(vertices.front);
    while(!rbtree.empty) {
        Vertex v = rbtree.front;
        rbtree.removeFront;
        foreach(e; v.edges) {
            if (v.cost+e.weight < e.end.cost) {
                rbtree.removeKey(e.end);
                e.end.cost = v.cost+e.weight;
                e.end.depth = v.depth+1;
                if (e.start is vertices.front) {
                    e.end.type = ++type;
                } else {
                    e.end.type = e.start.type;
                }
                rbtree.insert(e.end);
            }
        }
    }

    long ans = reduce!min(INF, vertices.map!(v => v.edges.filter!(e =>
        e.start.type!=e.end.type && ((e.start.depth-e.end.depth).abs>1 || (e.start.type>0 && e.end.type>0))
    )).join.map!(e => e.start.cost+e.end.cost+e.weight));
    writeln(ans==INF ? -1:ans);
}

class Vertex{
    int index;
    int depth;
    int type;
    Edge[] edges;
    long cost;
    this(int index) {
        this.index = index;
        cost = INF;
    }
    override string toString() const {return index.to!string;}
}

struct Edge {
    Vertex start, end;
    long weight;
    this(Vertex start, Vertex end, long weight) {
        this.start = start;
        this.end = end;
        this.weight = weight;
    }
}
