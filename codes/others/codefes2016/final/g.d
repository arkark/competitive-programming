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
void times(alias fun)(int n) {
    foreach(i; 0..n) fun();
}
auto rep(alias fun, T = typeof(fun()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = fun();
    return res;
}
// fold was added in D 2.071.0.
template fold(fun...) if (fun.length >= 1) {
    auto fold(R, S...)(R r, S seed) {
        static if (S.length < 2) {
            return reduce!fun(seed, r);
        } else {
            return reduce!fun(tuple(seed), r);
        }
    }
}

long INF = long.max/3;
void main() {
    int N, Q;
    readf("%d %d\n", &N, &Q);

    auto tree = redBlackTree!((a, b) => a.w < b.w, true, Edge)([]);
    Edge[] es = N.iota.map!(i => Edge(i, (i+1)%N, INF)).array;
    Q.times!({
        int a, b, c;
        readf("%d %d %d\n", &a, &b, &c);
        tree.insert(Edge(a, b, c));
        es[a].w = min(es[a].w, c+1);
        es[b].w = min(es[b].w, c+2);
    });
    foreach(i; 0..N*2) {
        es[(i+1)%N].w = min(es[(i+1)%N].w, es[i%N].w + 2);
    }
    tree.insert(es);

    long ans = 0;
    auto set = DisjointSet(N);
    tree[].each!((e){
        if (!set.same(e.s, e.g)) {
            set.unite(e.s, e.g);
            ans += e.w;
        }
    });
    ans.writeln;
}

struct Edge {
    int s, g;
    long w;
}

// 互いに素な集合
// UnionFindTreeによる実装
struct DisjointSet {

private:
    Vertex[] _vertices;

public:
    this(size_t size) {
        _vertices = new Vertex[size];
        foreach(i, ref v; _vertices) {
            v.index = i;
            v.parent = i;
        }
    }

    void makeSet(size_t[] indices...) {
        foreach(index; indices) {
            _vertices[index] = Vertex(index, index);
        }
    }

    void unite(size_t x, size_t y) {
        link(findSet(x), findSet(y));
    }

    void link(size_t x, size_t y) {
        if (x==y) return;
        if (_vertices[x].rank > _vertices[y].rank) {
            _vertices[y].parent = x;
        } else {
            _vertices[x].parent = y;
            if (_vertices[x].rank == _vertices[y].rank) {
                _vertices[y].rank++;
            }
        }
    }

    bool same(size_t x, size_t y) {
        return findSet(x) == findSet(y);
    }

    size_t findSet(size_t index) {
        if (_vertices[index].parent == index) {
            return index;
        } else {
            return _vertices[index].parent = findSet(_vertices[index].parent);
        }
    }

private:
    struct Vertex {
        size_t index;
        size_t parent;
        size_t rank = 1;
    }
}
