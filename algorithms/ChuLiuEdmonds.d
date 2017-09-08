import std.range;
import std.algorithm;
import std.container : DList;

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
        auto list = DList!Vertex();
        size_t[] cnt = new size_t[_size];
        foreach(v; _vertices) {
            if (v.hasEdge) cnt[v.minEdge.start.index]++;
        }
        foreach(i, c; cnt) {
            if (c==0) list.insertBack(_vertices[i]);
        }
        while(!list.empty) {
            Vertex v = list.front;
            list.removeFront;
            if (v.hasEdge) {
                size_t i = v.minEdge.start.index;
                if (--cnt[i]==0) {
                    list.insertBack(_vertices[i]);
                }
            }
        }
        foreach(i, c; cnt) {
            if (c > 0) {
                // 閉路が検出された
                Vertex v = _vertices[i];
                Vertex u = v;
                do {
                    u.onCycle = true;
                    u = u.minEdge.start;
                } while(u !is v);
                return rec(v) + _vertices.filter!"a.onCycle".map!"a.minEdge.weight".sum;
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
