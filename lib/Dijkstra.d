// Dijkstra's algorithm
// O((V+E)logV)
struct Dijkstra(T) {
  import std.algorithm : map;
  import std.array : array;
  import std.container : redBlackTree;

private:
  Vertex[] vertices;
  long inf;

public:
  this(size_t size, T inf = T.max) {
    this.inf = inf;
    vertices.length = size;
    foreach (i; 0 .. size) {
      vertices[i] = new Vertex(i, inf);
    }
  }

  void addEdge(size_t begin, size_t end, T weight) {
    vertices[begin].edges ~= Edge(vertices[end], weight);
  }

  T[] solve(size_t start) {
    foreach (v; vertices) {
      v.cost = inf;
    }
    vertices[start].cost = 0;

    auto tree = redBlackTree!(
        "a.cost != b.cost ? a.cost < b.cost : a.index < b.index",
        Vertex,
    )(vertices[start]);
    while (!tree.empty) {
      auto v = tree.front;
      tree.removeFront;
      foreach (e; v.edges) {
        auto u = e.end;
        T cost = v.cost + e.weight;
        if (cost < u.cost) {
          tree.removeKey(u);
          u.cost = cost;
          tree.insert(u);
        }
      }
    }
    return vertices.map!"a.cost".array;
  }

private:
  class Vertex {
    size_t index;
    T cost;
    Edge[] edges;

    this(size_t index, T cost) {
      this.index = index;
      this.cost = cost;
    }

    // for old compilers
    override string toString() const {
      return "";
    }
  }

  struct Edge {
    Vertex end;
    T weight;
  }
}
