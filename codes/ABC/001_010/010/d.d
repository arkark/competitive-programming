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

const int INF = 1<<30;
int N, G, E;
Vertex[] vertices;
void main() {
    int[] input = readln.split.to!(int[]);
    N = input[0];
    G = input[1];
    E = input[2];

    vertices = (N+1).iota.map!(i => new Vertex(i)).array;
    foreach(p; readln.split.to!(int[])) {
        vertices[p].edges ~= new Edge(vertices.back, 1);
    }
    foreach(e; E.iota.map!(_ => readln.split.to!(int[]))) {
        vertices[e[0]].edges ~= new Edge(vertices[e[1]], 1);
        vertices[e[1]].edges ~= new Edge(vertices[e[0]], 1);
        vertices[e[0]].edges.back.rev = vertices[e[1]].edges.back;
        vertices[e[1]].edges.back.rev = vertices[e[0]].edges.back;
    }

    solve(vertices.front, vertices.back).writeln;
}

int solve(Vertex start, Vertex end) {
    int flow = 0;
    int f;
    while((f = dfs(start, end, INF, new bool[N+1])) > 0) {
        flow += f;
    }
    return flow;
}

int dfs(Vertex v, Vertex end, int flow, bool[] used) {
    if (v is end) return flow;
    used[v.index] = true;

    foreach(edge; v.edges) {
        if (!used[edge.end.index] && edge.cap>0) {
            int f = dfs(edge.end, end, min(flow, edge.cap), used);
            if (f > 0) {
                edge.cap -= f;
                if (edge.rev) edge.rev.cap += f;
                return f;
            }
        }
    }
    return 0;
}

class Vertex {
    size_t index;
    Edge[] edges = [];
    this(size_t index) {
        this.index = index;
    }
}
class Edge {
    Vertex end;
    int cap;
    Edge rev;
    this(Vertex end, int cap) {
        this.end = end;
        this.cap = cap;
    }
}
