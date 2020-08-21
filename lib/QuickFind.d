struct QuickFind {
  import std.algorithm : swap;

private:
  size_t[] i2g;
  size_t[][] gs;

public:
  this(size_t size) {
    init(size);
  }

  void init(size_t size) {
    gs.length = size;
    i2g.length = size;
    foreach (i; 0 .. size) {
      gs[i] = [i];
      i2g[i] = i;
    }
  }

  void unite(size_t x, size_t y) {
    if (gs[i2g[x]].length < gs[i2g[y]].length) {
      swap(x, y);
    }
    size_t gx = i2g[x], gy = i2g[y];
    if (gx == gy)
      return;
    foreach (i; gs[gy]) {
      i2g[i] = gx;
    }
    gs[gx] ~= gs[gy];
    gs[gy].length = 0;
  }

  bool same(size_t x, size_t y) {
    return findSet(x) == findSet(y);
  }

  size_t findSet(size_t index) {
    return i2g[index];
  }

  bool isRoot(size_t index) {
    return findSet(index) == index;
  }

  size_t[] getSet(size_t index) {
    return gs[findSet(index)];
  }

  size_t[][] getAllSet() {
    return gs;
  }
}
