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
    int N = readln.chomp.to!int;
    int[][] data = new int[][](N, N);
    foreach(i; 0..N) {
        data[i] = readln.chomp.split(",").map!(s => s=="-" ? -1:s.to!int).array;
    }
    auto prim = Prim!int(N);
    int ans = 0;
    foreach(i; 0..N) foreach(j; i+1..N) {
        if (data[i][j] != -1) {
            prim.setEdge(i, j, data[i][j]);
            ans += data[i][j];
        }
    }
    ans -= prim.solve;
    ans.writeln;
}

// プリム法
// O(E+VlogV)
struct Prim(T) {
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

    void setEdge(size_t start, size_t end, T weight) {
        _vertices[start].edges ~= Edge(start, end, weight);
        _vertices[end].edges ~= Edge(end, start, weight);
    }

    void setEdge(T[] input) {
        setEdge(cast(size_t) input[0], cast(size_t) input[1], input[2]);
    }

    T solve() {
        _vertices.front.cost = 0;
        auto rbtree = redBlackTree!"a.cost==b.cost ? a.index<b.index : a.cost<b.cost"(_vertices.front);
        while(!rbtree.empty) {
            Vertex v = rbtree.front;
            v.flag = true;
            rbtree.removeFront;
            v.edges.each!((Edge e) {
                if (_vertices[e.end].flag) return;
                rbtree.removeKey(_vertices[e.end]);
                _vertices[e.end].cost = min(_vertices[e.end].cost, e.weight);
                rbtree.insert(_vertices[e.end]);
            });
        }
        return reduce!"a + b.cost"(0, _vertices);
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
