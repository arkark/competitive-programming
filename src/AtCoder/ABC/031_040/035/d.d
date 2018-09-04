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

const long INF = 1<<30;
void main() {
    int[] input = readln.split.to!(int[]);
    int N = input[0];
    int M = input[1];
    int T = input[2];


    long[] A = readln.split.to!(long[]);
    Dijkstra!long d1 = Dijkstra!long(N, INF);
    Dijkstra!long d2 = Dijkstra!long(N, INF);
    foreach(i; 0..M) {
        input = readln.split.to!(int[]);
        d1.addEdge(input[0]-1, input[1]-1, input[2]);
        d2.addEdge(input[1]-1, input[0]-1, input[2]);
    }
    long[] ary1 = d1.solve(0);
    long[] ary2 = d2.solve(0);
    long ans = 0;
    foreach(i; 0..N) {
        ans = max(ans, (T-(ary1[i]+ary2[i]))*A[i]);
    }
    ans.writeln;
}

struct Dijkstra(T) {
    import std.algorithm;
    import std.container; // rbtree
private:
    Vertex[] _vertices;

public:
    this(size_t size, T inf = T.max) {
        _vertices.length = size;
        foreach(i; 0..size) {
            _vertices[i] = new Vertex(i, inf);
        }
    }

    void addEdge(size_t start, size_t end, T weight) {
        _vertices[start].edges ~= Edge(start, end, weight);
    }

    void addEdge(T[] input) {
        addEdge(cast(size_t) input[0], cast(size_t) input[1], input[2]);
    }

    T[] solve(size_t start, size_t end = -1) {
        _vertices[start].cost = 0;
        auto rbtree = redBlackTree!"a.cost==b.cost ? a.index<b.index : a.cost<b.cost"(_vertices[start]);
        while(!rbtree.empty) {
            Vertex v = rbtree.front;
            if (v.index == end) break;
            v.flag = true;
            rbtree.removeFront;
            v.edges.each!((Edge e) {
                if (_vertices[e.end].flag) return;
                if (v.cost+e.weight < _vertices[e.end].cost) {
                    rbtree.removeKey(_vertices[e.end]);
                    _vertices[e.end].cost = v.cost+e.weight;
                    rbtree.insert(_vertices[e.end]);
                }
            });
        }
        return _vertices.map!(v => v.cost).array;
    }

    Vertex[] getVertices() {
        return _vertices;
    }

private:
    class Vertex {
        size_t index;
        bool flag;
        T cost;
        Edge[] edges = [];
        this(size_t index, T cost) {
            this.index = index;
            this.cost = cost;
        }
        override string toString() const {return "";} // dlangの仕様
    }
    struct Edge {
        size_t start;
        size_t end;
        T weight;
    }
}
