struct UnionFind {

private:
  Vertex[] _vertices;
  size_t[] _sizes;

public:
  this(size_t n) {
    init(n);
  }

  void init(size_t n) {
    _vertices.length = n;
    _sizes.length = n;
    foreach(i, ref v; _vertices) {
      v.index = i;
      v.parent = i;
      _sizes[i] = 1;
    }
  }

  void unite(size_t x, size_t y) {
    link(findSet(x), findSet(y));
  }

  void link(size_t x, size_t y) {
    if (x==y) return;
    if (_vertices[x].rank > _vertices[y].rank) {
      _sizes[x] += _sizes[y];
      _vertices[y].parent = x;
    } else {
      _sizes[y] += _sizes[x];
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

  bool isRoot(size_t index) {
    return _vertices[index].parent == index;
  }

  size_t size(size_t index) {
    return _sizes[findSet(index)];
  }

private:
  struct Vertex {
    size_t index;
    size_t parent;
    size_t rank = 1;
  }
}
