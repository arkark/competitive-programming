
struct UnionFind {

private:
  Vertex[] _vertices;

public:
  this(size_t size) {
    init(size);
  }

  void init(size_t size) {
    _vertices.length = size;
    foreach(i, ref v; _vertices) {
      v.index = i;
      v.parent = i;
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
