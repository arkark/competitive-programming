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
import std.datetime;
void times(int n, void delegate() pred) {
    foreach(i; 0..n) pred();
}
T[] rep(T)(int n, T delegate() pred) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

void main() {
    int N, M, S;
    readf("%d %d %d\n", &N, &M, &S);
    S--;

    Vertex[] vertices = N.iota.map!(i => new Vertex(i)).array;
    M.times({
        int u, v;
        readf("%d %d\n", &u, &v);
        u--; v--;
        Edge e = new Edge(vertices[u], vertices[v]);
        vertices[u].edges1 ~= e;
        vertices[v].edges1 ~= e;
    });

    {
        bool[] used = new bool[N];
        auto list = DList!Vertex(vertices[S]);
        vertices[S].value = 1;
        vertices[S].edges2 = vertices[S].edges1;
        while(!list.empty) {
            Vertex v = list.front;
            used[v.index] = true;
            list.removeFront;
            foreach(edge; v.edges2) {
                Vertex _v = edge.get(v);
                _v.value += v.value;
                if (!_v.edges2.empty) {
                    _v.edges1 = _v.edges2;
                    _v.edges2 = [];
                }
                foreach(e; _v.edges1) {
                    if (e.get(_v) !is v) {
                        _v.edges2 ~= e;
                    }
                }
                if (!used[_v.index]) {
                    list.insertBack(_v);
                }
            }
        }
    }

    foreach(i; 0..N) {
        if (vertices[i].value>0) {
            writeln(i+1);

            bool[] used = new bool[N];
            auto list = DList!Vertex(vertices[i]);
            long value = vertices[i].value;
            while(!list.empty) {
                Vertex v = list.front;
                used[v.index] = true;
                list.removeFront;
                foreach(edge; v.edges2) {
                    edge.get(v).value -= value;
                    if (!used[edge.get(v).index]) {
                        list.insertBack(edge.get(v));
                    }
                }
            }
        }
    }
}

class Vertex {
    int index;
    long value;
    Edge[] edges1;
    Edge[] edges2;
    this(int index) {
        this.index = index;
    }
}

class Edge {
    Vertex v1, v2;
    this(Vertex v1, Vertex v2) {
        this.v1 = v1;
        this.v2 = v2;
    }
    Vertex get(Vertex v) {
        return (v1 is v) ? v2 : v1;
    }
}
