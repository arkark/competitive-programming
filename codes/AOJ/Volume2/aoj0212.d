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

int[][] dp;
void main() {
    while(true) {
        int[] input = readln.split.to!(int[]);
        if (input == [0, 0, 0, 0, 0]) break;
        int c = input[0];
        int n = input[1];
        int m = input[2];
        int s = input[3]-1;
        int d = input[4]-1;
        auto dijkstra = Dijkstra!int(n);
        foreach(i; 0..m) {
            input = readln.split.to!(int[]);
            dijkstra.setEdge(input[0]-1, input[1]-1, input[2]);
        }
        dp = new int[][](c+1, n);
        foreach(i; 0..c+1) {
            dijkstra.refresh();
            dijkstra.solve(s, d, i);
        }
        dp.back[d].writeln;
    }
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

    void refresh() {
        foreach(v; _vertices) {
            v.flag = false;
            v.cost = T.max;
        }
    }

    void setEdge(size_t start, size_t end, T weight) {
        _vertices[start].edges ~= Edge(start, end, weight);
        _vertices[end].edges ~= Edge(end, start, weight);
    }

    void setEdge(T[] input) {
        setEdge(cast(size_t) input[0], cast(size_t) input[1], input[2]);
    }

    T solve(size_t start, size_t end, int c) {
        _vertices[start].cost = 0;
        auto rbtree = redBlackTree!"a.cost==b.cost ? a.index<b.index : a.cost<b.cost"(_vertices[start]);
        while(!rbtree.empty) {
            Vertex v = rbtree.front;
            dp[c][v.index] = v.cost;
            //if (v.index == end) break;
            v.flag = true;
            rbtree.removeFront;
            v.edges.each!((Edge e) {
                if (_vertices[e.end].flag) return;
                T temp;
                if (c==0) {
                    temp = v.cost+e.weight;
                } else {
                    temp = min(v.cost+e.weight, dp[c-1][_vertices[e.start].index]+e.weight/2);
                }
                if (temp < _vertices[e.end].cost) {
                    rbtree.removeKey(_vertices[e.end]);
                    _vertices[e.end].cost = temp;
                    rbtree.insert(_vertices[e.end]);
                }
            });
        }
        return _vertices[end].cost;
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
