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

int N, M;
void main() {
    readf("%d %d\n", &N, &M);

    Edge[] edges = M.rep!({
        int a, b, c;
        readf("%d %d %d\n", &a, &b, &c);
        a--; b--;
        return Edge(a, b, c);
    }).sort!((a, b) => a.w < b.w).array;

    int Q = readln.chomp.to!int;

    if (Q>1) return; //

    foreach(_; 0..Q) {
        int s, t;
        readf("%d %d\n", &s, &t);
        s--; t--;
        auto set = DisjointSet(N);
        set.unite(s, t);
        long res = 0;
        edges.each!((e) {
            if (!set.same(e.s, e.t)) {
                set.unite(e.s, e.t);
                res += e.w;
            }
        });
        res.writeln;
    }
}

bool check(DisjointSet set) {
    size_t[] res = N.iota.map!(i => set.findSet(i)).array;
    return res.all!(a => a==res.front);
}

struct Edge {
    int s, t;
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
