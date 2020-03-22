// LCA: Lowest Common Ancestor
//   using EulerTour & SegTree

version(unittest) {
  mixin(import("SegTree.d"));
}

struct LCA {
  import std.algorithm : each, map, min, max;

private:
  alias SegT = SegTree!(SegNode, (a, b) => a.depth<b.depth ? a:b, SegNode(int.max, size_t.max));

  size_t _size;
  Vertex[] _vertices;
  size_t _rootIndex;
  SegT _segT;
  bool _builded;

public:
  // O(N)
  this(size_t size) {
    _size = size;
    _vertices.length = size;
    foreach(i, ref v; _vertices) {
      v = new Vertex(i);
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
    return querySegNode(x, y).index;
  }

  // O(log N)
  int queryDepth(size_t x, size_t y) {
    return querySegNode(x, y).depth;
  }

  // O(1)
  int getDepth(size_t x) {
    // return queryDepth(x, x);
    if (!_builded) build();
    return _segT.get(_vertices[x].id).depth;
  }

private:

  // O(N)
  void build() {
    _vertices.each!(v => v.visited = false);

    // Euler tour
    SegNode[] segNodes = new SegNode[2*_size];
    size_t dfs(Vertex v, int depth, size_t id) {
      segNodes[id].depth = depth;
      segNodes[id].index = v.index;
      v.id = id;
      foreach(u; v.edges.map!"a.end") {
        if (u.visited) continue;
        u.visited = true;
        id = dfs(u, depth + 1, id + 1) + 1;
        segNodes[id].depth = depth;
        segNodes[id].index = v.index;
      }
      return id;
    }
    _vertices[_rootIndex].visited = true;
    dfs(_vertices[_rootIndex], 0, 0);

    _segT = SegT(segNodes);

    _builded = true;
  }

  // O(log N)
  SegNode querySegNode(size_t x, size_t y) {
    if (!_builded) build();
    size_t idX = _vertices[x].id;
    size_t idY = _vertices[y].id;
    return _segT.query(min(idX, idY), max(idX, idY) + 1);
  }

  class Vertex {
    size_t index;
    size_t id;
    bool visited;
    Edge[] edges;
    this(size_t index) {
      this.index = index;
    }
  }
  struct Edge {
    Vertex start, end;
  }
  struct SegNode {
    int depth;
    size_t index;
  }
}
