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
void times(int n, void delegate() pred) {
    foreach(i; 0..n) pred();
}
T[] rep(T)(int n, T delegate() pred) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

int INF = 1<<25;
void main() {
    int N, M;
    readf("%d %d\n", &N, &M);

    DisjointSet set = DisjointSet(N);

    auto t = M.rep(()=>readln.split.to!(int[])).tee!((a) {
        a[0]--; a[1]--;
    }).array.sort!((a, b) => a[2]>b[2]).array;

    int Q = readln.chomp.to!int;
    auto s = Q.rep({
        int v, w;
        readf("%d %d\n", &v, &w);
        v--;
        return [v, w];
    }).enumerate.array.sort!((a, b) => a.value[1]>b.value[1]).array;

    int[] ans = new int[Q];
    int now = 0;
    foreach(i; 0..Q) {
        while(now<M && t[now][2] > s[i].value[1]) {
            set.unite(t[now][0], t[now][1]);
            now++;
        }
        ans[s[i].index] = set.getNum(s[i].value[0]);
    }

    ans.each!writeln;
}

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
    this(Vertex[] vs) {
        _vertices = vs.dup;
    }

    void makeSet(size_t[] indices...) {
        foreach(index; indices) {
            _vertices[index] = Vertex(index, index);
        }
    }

    void unite(size_t x, size_t y) {
        link(find(x), find(y));
    }

    void link(size_t x, size_t y) {
        if (x==y) return;
        if (_vertices[x].rank > _vertices[y].rank) {
            _vertices[y].parent = x;
            _vertices[x].num += _vertices[y].num;
        } else {
            _vertices[x].parent = y;
            _vertices[y].num += _vertices[x].num;
            if (_vertices[x].rank == _vertices[y].rank) {
                _vertices[y].rank++;
            }
        }
    }

    bool same(size_t x, size_t y) {
        return find(x) == find(y);
    }

    size_t find(size_t index) {
        if (_vertices[index].parent == index) {
            return index;
        } else {
            return _vertices[index].parent = find(_vertices[index].parent);
        }
    }

    Vertex[] vertices() @property {
        return _vertices;
    }

    int getNum(size_t index) {
        return _vertices[find(index)].num;
    }

private:
    struct Vertex {
        size_t index;
        size_t parent;
        size_t rank = 1;
        int num = 1;
    }
}
