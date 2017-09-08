// Chu-Liu/Edmonds' algorithm
//   最小有向全域木を求める
class ChuLiuEdmonds(T) {

private:
    size_t _size;
    Vertex[] _vertices;
    Vertex _root;

public:
    this(size_t size, size_t rootIndex) {
        _size = size;
        _vertices = size.iota.map!(i => new Vertex(i)).array;
        _root = _vertices[rootIndex];
    }

    void addEdge(size_t startIndex, size_t endIndex, T weight) {
        if (endIndex == _root.index) return; // rootに入る辺は除外する（最小木に含まれる可能性がないため）
        if (startIndex == endIndex) return; // 自己ループは除外する
        Vertex start = _vertices[startIndex];
        Vertex end   = _vertices[endIndex];
        end.edges ~= Edge(start, end, weight);
    }

    // O(V(V + E)) = O(VE)
    T solve() {
        foreach(v; _vertices) {
            if (!v.hasEdge) continue;
            v.minEdge = v.edges.minElement!"a.weight";
        }

        // v を含む閉路を縮約したグラフの最小コストを返す
        auto rec(Vertex v) {
            auto sub = new ChuLiuEdmonds!T(_size, _root.index);
            auto getIndex  = (Vertex u) => u.onCycle ? v.index : u.index;
            foreach(u; _vertices) {
                foreach(e; u.edges) {
                    sub.addEdge(
                        getIndex(e.start),
                        getIndex(e.end),
                        e.weight - (u.onCycle ? u.minEdge.weight : 0)
                    );
                }
            }
            return sub.solve;
        }

        // 閉路検出
        foreach(v; _vertices) {
            if (v.isVisited) continue;
            if (!v.hasEdge) continue;

            Vertex u1 = v;
            Vertex u2 = v.minEdge.start;
            while(true) {
                u1.isVisited = true;
                u2.isVisited = true;
                if (u1 is _root) break;
                if (u2 is _root) break;
                if (u1 is u2) {
                    // 閉路が検出された
                    do {
                        u1.onCycle = true;
                        u1 = u1.minEdge.start;
                    } while(u1 !is u2);
                    return rec(u1) + _vertices.filter!"a.onCycle".map!"a.minEdge.weight".sum;
                }
                u1 = u1.minEdge.start;
                u2 = u2.minEdge.start;
                if (u2 is _root) break;
                u2 = u2.minEdge.start;
            }
        }

        // 閉路が検出されなかったとき
        return _vertices.filter!"a.hasEdge".map!"a.minEdge.weight".sum;
    }

private:
    class Vertex {
        size_t index;
        Edge[] edges; // assert(edges.all!(e => e.end is this))
        Edge minEdge;
        bool onCycle = false;
        bool isVisited = false;
        this(size_t index) {
            this.index = index;
        }
        bool hasEdge() {
            return edges.length > 0;
        }
    }

    struct Edge {
        Vertex start, end;
        T weight;
    }

}
