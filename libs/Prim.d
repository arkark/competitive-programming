// プリム法
// O(E+VlogV)
// 無向グラフの最小全域木問題
struct Prim(T, T inf = T.max) {

private:
    Vertex[] _vertices;

public:
    this(size_t size) {
        _vertices.length = size;
        foreach(i; 0..size) {
            _vertices[i] = new Vertex(i);
        }
    }

    void addEdge(size_t start, size_t end, T weight) {
        _vertices[start].edges ~= Edge(start, end, weight);
        _vertices[end].edges   ~= Edge(end, start, weight);
    }

    T solve() {
        _vertices.front.cost = 0;
        auto tree = redBlackTree!(
            "a.cost==b.cost ? a.index<b.index : a.cost<b.cost",
            true,
            Vertex
        )(_vertices.front);
        while(!tree.empty) {
            Vertex v = tree.front;
            v.used = true;
            tree.removeFront;
            v.edges.each!((Edge e) {
                if (_vertices[e.end].used) return;
                tree.removeKey(_vertices[e.end]);
                _vertices[e.end].cost = min(_vertices[e.end].cost, e.weight);
                tree.insert(_vertices[e.end]);
            });
        }
        return _vertices.map!"a.cost".sum;
    }

private:
    class Vertex {
        size_t index;
        bool used;
        T cost = inf;
        Edge[] edges;
        this(size_t index) {
            this.index = index;
        }
        override string toString() {return "";} //
    }
    struct Edge {
        size_t start;
        size_t end;
        T weight;
    }
}
