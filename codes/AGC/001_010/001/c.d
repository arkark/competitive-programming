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

int INF = 1<<25;
void main() {
    int N, K;
    readf("%d %d\n", &N, &K);

    Vertex[] vertices = N.rep(() => new Vertex());
    Edge[] edges = (N-1).rep({
        int a, b;
        readf("%d %d\n", &a, &b);
        a--; b--;
        vertices[a].edges ~= Edge(vertices[a], vertices[b]);
        vertices[b].edges ~= Edge(vertices[b], vertices[a]);
        return Edge(vertices[a], vertices[b]);
    });

    if (K%2==0) {
        vertices.map!((s) {
            vertices.each!(v => v.depth = INF);
            auto list = DList!(Vertex)(s);
            s.depth = 0;
            while (!list.empty) {
                Vertex v = list.front;
                list.removeFront;
                v.edges.each!((e) {
                    if (e.end.depth <= v.depth+1) return;
                    e.end.depth = v.depth+1;
                    list.insertBack(e.end);
                });
            }
            return vertices.count!(v => v.depth>K/2);
        }).reduce!min.writeln;
    } else {
        edges.map!((s) {
            vertices.each!(v => v.depth = INF);
            auto list = DList!(Vertex)([s.start, s.end]);
            s.start.depth = 0;
            s.end.depth = 0;
            while (!list.empty) {
                Vertex v = list.front;
                list.removeFront;
                v.edges.each!((e) {
                    if (e.end.depth <= v.depth+1) return;
                    e.end.depth = v.depth + 1;
                    list.insertBack(e.end);
                });
            }
            return vertices.count!(v => v.depth>(K-1)/2);
        }).reduce!min.writeln;
    }
}

class Vertex{
    Edge[] edges;
    int depth;
}

struct Edge {
    Vertex start, end;
}
