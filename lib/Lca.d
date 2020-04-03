// LCA: Lowest Common Ancestor
//   using EulerTour & SegTree

version(unittest) {
  mixin(import("SegTree.d"));
}

struct Lca {
  import std.algorithm : each, map, min, max;

private:
  alias SegT = SegTree!(SegNode, (a, b) => a.depth<b.depth ? a:b, SegNode(long.max, size_t.max));

  Vertex[] _vertices;
  SegT _segT;

  bool _builded;

public:
  // O(N)
  this(size_t n) {
    _vertices.length = n;
    foreach(i, ref v; _vertices) {
      v = new Vertex(i);
    }
    _builded = false;
  }

  // O(1)
  size_t size() {
    return _vertices.length;
  }

  // O(1)
  void addEdge(size_t x, size_t y) {
    _vertices[x].adj ~= _vertices[y];
    _vertices[y].adj ~= _vertices[x];
    _builded = false;
  }

  // O(n)
  void build(size_t rootIndex = 0) {
    execEulerTour(rootIndex);
    _builded = true;
  }

  // ノードx,yのLCAのノードインデックス
  // O(log N)
  size_t queryIndex(size_t x, size_t y) in {
    assert(_builded);
  } body {
    return querySegNode(x, y).index;
  }

  // ノードx,yのLCAの深さ
  // O(log N)
  long queryDepth(size_t x, size_t y) in {
    assert(_builded);
  } body {
    return querySegNode(x, y).depth;
  }

  // ノードxの深さ
  // O(1)
  long getDepth(size_t x) in {
    assert(_builded);
  } body {
    return _segT.get(_vertices[x].firstId).depth;
  }

private:

  // O(N)
  void execEulerTour(size_t rootIndex) {
    SegNode[] segNodes = new SegNode[2*size];

    // @return: next id
    size_t dfs(Vertex v, Vertex parent, long depth, size_t id) {
      segNodes[id].depth = depth;
      segNodes[id].index = v.index;
      v.firstId = id;
      foreach(u; v.adj) {
        if (u is parent) continue;
        id = dfs(u, v, depth + 1, id + 1);
        segNodes[id].depth = depth;
        segNodes[id].index = v.index;
      }
      return id + 1;
    }
    dfs(_vertices[rootIndex], null, 0, 0);

    _segT = SegT(segNodes);
  }

  // O(log N)
  SegNode querySegNode(size_t x, size_t y) {
    size_t idX = _vertices[x].firstId;
    size_t idY = _vertices[y].firstId;
    return _segT.query(min(idX, idY), max(idX, idY) + 1);
  }

  class Vertex {
    size_t index;
    size_t firstId;
    Vertex[] adj;
    this(size_t index) {
      this.index = index;
    }
  }
  struct SegNode {
    long depth;
    size_t index;
  }
}
