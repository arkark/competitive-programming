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
import std.concurrency;
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

void main() {
    int H, W;
    readf("%d %d\n", &H, &W);
    solve(
        H.rep!(() => readln.chomp.map!(c => c-'0').array.to!(int[]))
    ).writeln;
}

long MOD = 10^^9+7;
long fact(long n) {
    return n < 2 ? 1 : n * memoize!fact(n - 1) % MOD;
}
long two(long n) {
    return n==0 ? 1 : 2 * memoize!two(n-1) % MOD;
}

long solve(int[][] grid) {
    return _solve(grid) % MOD;
}
long _solve(int[][] grid) {
    if (grid.empty) return 1;
    int H = grid.length.to!int;
    int W = grid.front.length.to!int;
    if (H%2==1) return solve(grid[0..$/2] ~ grid[$/2+1..$]) * (grid[$/2].pipe!(ary => ary.equal(ary.retro)) ? 1:2);
    if (W%2==1) return solve(grid.transposed.map!array.array);

    H /= 2; W /= 2;
    long res = 1;

    auto set = DisjointSet(H+W);

    foreach(i; 0..H) foreach(j; 0..W) {
        uint[] ary = [grid[i][j], grid[i][j+W], grid[i+H][j], grid[i+H][j+W]].sort().group.map!(a => a[1]).array.sort!"a>b".array;
        res = res * fact(4) / ary.map!fact.reduce!"a*b";
        if (ary.front == 4) {
            res /= 2;
            set.unite(i, H+j);
        }
    }

    res *= two(H+W - set._vertices.map!(v => v.parent).array.sort().uniq.array.length);

    return res;
}

// 互いに素な集合
// UnionFindTreeによる実装
struct DisjointSet {
    Vertex[] _vertices;

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
