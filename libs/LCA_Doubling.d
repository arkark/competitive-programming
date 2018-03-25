// LCA: Lowest Common Ancestor
//   using Doubling Technique

struct LCA {

private:
    size_t _size;
    size_t _logSize;
    Vertex[] _vertices;
    size_t _rootIndex;
    bool _builded;

public:

    this(size_t size) {
        _size = size;
        _logSize = cast(size_t)(log2(_size) + 2);
        _vertices.length = _size;
        foreach(i, ref v; _vertices) {
            _vertices[i] = new Vertex;
            _vertices[i].index = i;
            _vertices[i].powParents.length = _logSize;
        }
        _rootIndex = 0;
        _builded = false;
    }

    // O(1)
    void addEdge(size_t x, size_t y) {
        _builded = false;
        Vertex vx = _vertices[x];
        Vertex vy = _vertices[y];
        vx.edges ~= Edge(vx, vy);
        vy.edges ~= Edge(vy, vx);
    }

    // O(1)
    void setRoot(size_t index) {
        _builded = false;
        _rootIndex = index;
    }

    // O(log N)
    size_t queryIndex(size_t x, size_t y) {
        return queryVertex(x, y).index;
    }

    // O(log N)
    int queryDepth(size_t x, size_t y) {
        return queryVertex(x, y).depth;
    }

    // O(1)
    int getDepth(size_t x) {
        // return queryDepth(x, x);
        if (!_builded) build();
        return _vertices[x].depth;
    }

private:

    // O(N log N)
    void build() {
        _vertices.each!(v => v.visited = false);

        void dfs(Vertex vertex, Vertex parent, int depth) {
            vertex.powParents[0] = parent;
            vertex.depth = depth;
            foreach(v; vertex.edges.map!"a.end") {
                if (v.visited) continue;
                v.visited = true;
                dfs(v, vertex, depth + 1);
            }
        }
        _vertices[_rootIndex].visited = true;
        dfs(_vertices[_rootIndex], null, 0);

        foreach(k; 1.._logSize) {
            foreach(v; _vertices) {
                if (v.powParents[k-1] is null) continue;
                v.powParents[k] = v.powParents[k-1].powParents[k-1];
            }
        }

        _builded = true;
    }

    Vertex queryVertex(size_t x, size_t y) {
        if (!_builded) build();

        Vertex vx = _vertices[x];
        Vertex vy = _vertices[y];

        if (vx.depth > vy.depth) swap(vx, vy);
        foreach(k; 0.._logSize) {
            if ((vy.depth - vx.depth)>>k&1) {
                vy = vy.powParents[k];
                assert(vy !is null);
            }
        }
        assert(vx.depth == vy.depth);
        if (vx is vy) return vx;

        foreach(k; _logSize.iota.retro) {
            if (vx.powParents[k] !is vy.powParents[k]) {
                vx = vx.powParents[k];
                vy = vy.powParents[k];
                assert(vx !is null && vy !is null);
            }
        }
        assert(vx.powParents[0] is vy.powParents[0]);

        return vx.powParents[0];
    }

    class Vertex {
        size_t index;
        int depth;
        bool visited;
        Vertex[] powParents; // powParents[i][j] = 頂点iから2^j回親を辿った頂点（いなければnull）
        Edge[] edges;
    }

    struct Edge {
        Vertex start, end;
    }

}
