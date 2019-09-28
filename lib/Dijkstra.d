// Dijkstra's algorithm
// O((V+E)logV)
struct Dijkstra(T) {
  import std.algorithm;
  import std.container; // rbtree
private:
  Vertex[] _vertices;

public:
  this(size_t size, T inf = T.max) {
    _vertices.length = size;
    foreach(i; 0..size) {
      _vertices[i] = new Vertex(i, inf);
    }
  }

  void addEdge(size_t start, size_t end, T weight) {
    _vertices[start].edges ~= Edge(start, end, weight);
  }

  void addEdge(T[] input) {
    addEdge(cast(size_t) input[0], cast(size_t) input[1], input[2]);
  }

  T[] solve(size_t start, size_t end = -1) {
    _vertices[start].cost = 0;
    auto rbtree = redBlackTree!"a.cost==b.cost ? a.index<b.index : a.cost<b.cost"(_vertices[start]);
    while(!rbtree.empty) {
      Vertex v = rbtree.front;
      if (v.index == end) break;
      v.flag = true;
      rbtree.removeFront;
      v.edges.each!((Edge e) {
        if (_vertices[e.end].flag) return;
        if (v.cost+e.weight < _vertices[e.end].cost) {
          rbtree.removeKey(_vertices[e.end]);
          _vertices[e.end].cost = v.cost+e.weight;
          rbtree.insert(_vertices[e.end]);
        }
      });
    }
    return _vertices.map!(v => v.cost).array;
  }

  Vertex[] getVertices() {
    return _vertices;
  }

private:
  class Vertex {
    size_t index;
    bool flag;
    T cost;
    Edge[] edges = [];
    this(size_t index, T cost) {
      this.index = index;
      this.cost = cost;
    }
    override string toString() const {return "";} // for old compilers
  }
  struct Edge {
    size_t start;
    size_t end;
    T weight;
  }
}
