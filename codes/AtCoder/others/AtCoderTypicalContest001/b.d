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

void main() {
    int[] input = readln.split.to!(int[]);
    int N = input[0];
    int Q = input[1];
    DisjointSet set = DisjointSet(N);
    foreach(i; 0..N) {
        set.makeSet(i);
    }
    foreach(i; 0..Q) {
        input = readln.split.to!(int[]);
        if (input[0]==0) {
            set.unite(input[1], input[2]);
        } else {
            writeln(set.same(input[1], input[2]) ? "Yes":"No");
        }
    }
}

struct DisjointSet {

private:
    Vertex[] _vertices;

public:
    this(size_t size) {
        _vertices = new Vertex[size];
    }

    void makeSet(size_t[] values...) {
        foreach(value; values) {
            _vertices[value] = Vertex(value, value);
        }
    }

    void unite(size_t x, size_t y) {
        link(compress(x), compress(y));
    }

    size_t compress(size_t x) {
        return (_vertices[x].parent = findSet(x));
    }

    void link(size_t x, size_t y) {
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

    size_t findSet(size_t value) {
        if (_vertices[value].parent != value) {
            value = _vertices[value].parent;
        }
        return value;
    }

private:
    struct Vertex {
        size_t value;
        size_t parent;
        size_t rank = 1;
    }
}
