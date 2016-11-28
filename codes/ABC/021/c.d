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

immutable int INF = 1<<25;
immutable long MOD = 10^^9+7;
void main() {
    int N, a, b, M;
    readf("%d\n%d %d\n%d\n", &N, &a, &b, &M);
    a--; b--;

    Vertex[] vertices = N.iota.map!(i => new Vertex).array;
    foreach(i; 0..M) {
        int[] input = readln.split.to!(int[]).map!"a-1".array;
        vertices[input[0]].edges1 ~= Edge(vertices[input[0]], vertices[input[1]]);
        vertices[input[1]].edges1 ~= Edge(vertices[input[1]], vertices[input[0]]);
    }

    vertices[a].depth = 0;
    auto list = DList!Vertex(vertices[a]);
    while(!list.empty) {
        Vertex v = list.front;
        list.removeFront;
        foreach(edge; v.edges1) {
            if (edge.end.depth==INF) {
                edge.end.depth = v.depth+1;
                list.insertBack(edge.end);
            }
        }
    }

    foreach(vertex; vertices) {
        foreach(edge; vertex.edges1) {
            if (edge.end.depth == vertex.depth+1) {
                vertex.edges2 ~= edge;
            }
        }
    }

    vertices[a].dp = 1;
    list.insertBack(vertices[a]);
    while(!list.empty) {
        Vertex v = list.front;
        list.removeFront;
        foreach(edge; v.edges2) {
            edge.end.dp = (edge.end.dp+edge.start.dp)%MOD;
            if (!edge.end.visited) list.insertBack(edge.end);
            edge.end.visited = true;
        }
    }

    vertices[b].dp.writeln;
}

class Vertex{
    int depth = INF;
    long dp;
    bool visited;
    Edge[] edges1;
    Edge[] edges2;
}

struct Edge{
    Vertex start, end;
}
