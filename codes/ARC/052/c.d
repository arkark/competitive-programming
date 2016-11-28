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
Vertex[] vertices;
int N, M;
void main() {
    int[] input = readln.split.to!(int[]);
    N = input[0];
    M = input[1];

    vertices = new Vertex[N];
    foreach(i, ref v; vertices) v = new Vertex(i);
    foreach(i; 0..M) {
        input = readln.split.to!(int[]);
        int C = input[0];
        int A = input[1];
        int B = input[2];
        vertices[A].edges ~= Edge(A, B, C);
        vertices[B].edges ~= Edge(B, A, C);
    }

    dijkstra1();
    dijkstra2();

    foreach(v; vertices) {
        // v.minB.writeln;
        v.cost.reduce!min.writeln;
    }
}

void dijkstra1() {
    vertices.each!(v => v.minB = INF);
    vertices.front.minB = 0;
    auto rbtree = redBlackTree!((a, b) =>
        a.minB==b.minB ? a.index<b.index : a.minB<b.minB
    )(vertices.front);

    while(!rbtree.empty) {
        Vertex v = rbtree.front;
        rbtree.removeFront;
        v.edges.each!((Edge e) {
            int c = v.minB + (e.type==0 ? 0:1);
            if (c < vertices[e.end].minB) {
                rbtree.removeKey(vertices[e.end]);
                vertices[e.end].minB = c;
                rbtree.insert(vertices[e.end]);
            }
        });
    }
}

void dijkstra2() {
    vertices.each!((Vertex v) {
        v.maxB = cast(int) ((-1 + sqrt(cast(double) (8*N-7+4*v.minB*(v.minB+1))))/2);
        v.cost.length = v.maxB-v.minB+1;
        v.cost[] = INF;
    });
    vertices.front.cost.front = 0;

    auto rbtree = redBlackTree!((x, y) {
        if (x.v.cost[x.b]!=y.v.cost[y.b]) return x.v.cost[x.b]<y.v.cost[y.b];
        if (x.b!=y.b) return x.b<y.b;
        return x.v.index<y.v.index;
    })(Node(vertices.front, 0));

    while(!rbtree.empty) {
        auto n = rbtree.front;
        rbtree.removeFront;
        n.v.edges.each!((Edge e) {
            if (e.type==0) {
                int c = n.v.cost[n.b]+1;
                int b = n.b+n.v.minB-vertices[e.end].minB;
                if (b<vertices[e.end].cost.length && c<vertices[e.end].cost[b]) {
                    rbtree.removeKey(Node(vertices[e.end], b));
                    vertices[e.end].cost[b] = c;
                    rbtree.insert(Node(vertices[e.end], b));
                }
            } else {
                int c = n.v.cost[n.b]+n.b+n.v.minB+1;
                int b = n.b+1+n.v.minB-vertices[e.end].minB;
                if (b<vertices[e.end].cost.length && c<vertices[e.end].cost[b]) {
                    rbtree.removeKey(Node(vertices[e.end], b));
                    vertices[e.end].cost[b] = c;
                    rbtree.insert(Node(vertices[e.end], b));
                }
            }
        });
    }
}

struct Node {
    Vertex v;
    int b;
    this(Vertex v, int b) {
        this.v = v;
        this.b = b;
    }
}

class Vertex {
    size_t index;
    int[] cost;
    int minB;
    int maxB;
    Edge[] edges = [];
    this(size_t index) {
        this.index = index;
    }
    override string toString() const {return "";}
}

struct Edge {
    size_t start;
    size_t end;
    int type;
}
