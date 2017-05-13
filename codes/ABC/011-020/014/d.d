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

void main() {
    int N = readln.chomp.to!int;
    Vertex[] vertices = new Vertex[N];
    foreach(i; 0..N-1) {
        int[] input = readln.split.to!(int[]).map!"a-1".array;
        vertices[input[0]].edges ~= Edge(input[0], input[1]);
        vertices[input[1]].edges ~= Edge(input[1], input[0]);
    }

    int[] ary;
    void rec(size_t i, int depth) {
        vertices[i].visited = true;
        vertices[i].index = ary.length;
        ary ~= depth;
        foreach(edge; vertices[i].edges) {
            if (!vertices[edge.end].visited) {
                rec(edge.end, depth+1);
                ary ~= depth;
            }
        }
    }
    rec(0, 0);
    auto rmq = SegTree!(int, (a, b) => a<b ? a:b, int.max)(ary);
    int Q = readln.chomp.to!int;
    foreach(i; 0..Q) {
        int[] input = readln.split.to!(int[]).map!"a-1".array;
        size_t x = vertices[input[0]].index;
        size_t y = vertices[input[1]].index;
        int z = rmq.query(min(x, y), max(x, y)+1);
        writeln((ary[x]-z)+(ary[y]-z)+1);
    }
}

struct Vertex{
    bool visited;
    size_t index;
    Edge[] edges;
}

struct Edge{
    size_t start, end;
}

// SegTree (Segment Tree)
struct SegTree(T, alias pred, T initValue)
    if (is(typeof(pred(T.init, T.init)) : T)) {

private:
    T[] _data;
    size_t _size;
    size_t _l, _r;

public:
    // size ... データ数
    // initValue ... 初期値(例えばRMQだとINF)
    this(size_t size) {
        init(size);
    }

    // 配列で指定
    this(T[] ary) {
        init(ary.length);
        update(ary);
    }

    void init(size_t size){
        _size = 1;
        while(_size < size) {
            _size *= 2;
        }
        _data.length = _size*2-1;
        _data[] = initValue;
        _l = 0;
        _r = size;
    }

    // i番目の要素をxに変更
    void update(size_t i, T x) {
        i += _size-1;
        _data[i] = x;
        while(i>0) {
            i = (i-1)/2;
            _data[i] = pred(_data[i*2+1], _data[i*2+2]);
        }
    }

    // 配列で指定
    void update(T[] ary) {
        foreach(size_t i, e; ary) {
            size_t _i = i+_size-1;
            _data[_i] = e;
        }
        foreach(i; 0.._size-1) {
            size_t _i = _size-i-2;
            _data[_i] = pred(_data[_i*2+1], _data[_i*2+2]);
        }
    }

    // 区間[a, b)でのクエリ
    T query(size_t a, size_t b) {
        return _query(a, b, 0, 0, _size);
    }
    T _query(size_t a, size_t b, size_t k, size_t l, size_t r) {
        if (b<=l || r<=a) return initValue;
        if (a<=l && r<=b) return _data[k];
        T vl = _query(a, b, k*2+1, l, (l+r)/2);
        T vr = _query(a, b, k*2+2, (l+r)/2, r);
        return pred(vl, vr);
    }

    T[] array() {
        return _data[_l+_size-1.._r+_size-1];
    }
}
