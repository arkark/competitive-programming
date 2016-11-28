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

void main() {
  int N, M;
  readf("%d %d\n", &N, &M);

  auto set = DisjointSet(N);
  int[] ary = M.rep!(() => -1);
  foreach(i; 0..N) {
    readln.split[1..$].to!(int[]).map!"a-1".each!((j) {
      if (ary[j] >=0) set.unite(ary[j], i);
      ary[j] = i;
    });
  }

  size_t[] res = N.iota.map!(i => set.findSet(i)).array;
  writeln(res.all!(a => a==res.front) ? "YES":"NO");
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
