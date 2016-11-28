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

    Vertex[] vs1 = N.iota.map!(i => new Vertex(i, -1)).array;
    Vertex[] vs2 = M.rep!(
        () => readln.split.to!(int[]).map!"a-1".array
    ).sort!(
        (a, b) => a[2]<b[2]
    ).chunkBy!(
        (a, b) => a[2]==b[2]
    ).map!((inputs) {
        Vertex[int] aa;
        inputs.each!((input) {
            int p=input[0], q=input[1], c=input[2];
            if (p !in aa) aa[p] = new Vertex(p, c);
            if (q !in aa) aa[q] = new Vertex(q, c);
            aa[p].edges ~= Edge(aa[p], aa[q], 0);
            aa[q].edges ~= Edge(aa[q], aa[p], 0);
        });
        foreach(i, v1; aa) {
            vs1[i].pipe!((v2) {
                v1.edges ~= Edge(v1, v2, 1);
                v2.edges ~= Edge(v2, v1, 0);
            });
        }
        return aa.byValue;
    }).join.array;

    vs1.front.d = 0;
    auto rbtree = redBlackTree!"a.d!=b.d ? a.d<b.d : a.c!=b.c ? a.c<b.c : a.index<b.index"(vs1.front);
    while (!rbtree.empty) {
        Vertex v = rbtree.front;
        rbtree.removeFront;
        v.edges.each!((e) {
            if (e.end.d > e.start.d + e.d) {
                rbtree.removeKey(e.end);
                e.end.d = e.start.d + e.d;
                rbtree.insert(e.end);
            }
        });
    }

    vs1.back.d.pipe!(a => a==INF ? -1:a).writeln;

}

class Vertex {
    long index;
    int c;
    long d;
    Edge[] edges;
    this(size_t index, int c) {
        this.index = index;
        this.c = c;
        d = INF;
    }
    override string toString() const {return "";}
}

struct Edge {
    Vertex start, end;
    long d;
}
