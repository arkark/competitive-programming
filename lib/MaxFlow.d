// maximum flow problem
//   Dinic's algorithm O(VE^2)

struct MaxFlow {
  import std.algorithm : min;

  enum long INF = long.max / 5;
  Vertex[] vertices;

public:
  this(size_t size) {
    vertices.length = size;
    foreach (ref v; vertices)
      v = new Vertex;
  }

  void addEdge(size_t start, size_t end, long capacity) {
    Edge e1 = new Edge(vertices[start], vertices[end], capacity);
    Edge e2 = new Edge(vertices[end], vertices[start], 0);
    e1.revEdge = e2;
    e2.revEdge = e1;
    vertices[start].edges ~= e1;
    vertices[end].edges ~= e2;
  }

  long solve(size_t s, size_t t) {
    long flow = 0;
    foreach (v; vertices) {
      foreach (e; v.edges) {
        e.capacity = e.initCapacity;
      }
    }
    while (true) {
      bfs(vertices[s]);
      if (vertices[t].level < 0)
        break;
      foreach (v; vertices)
        v.iter = 0;
      long f = 0;
      while ((f = dfs(vertices[s], vertices[t], INF)) > 0) {
        flow += f;
      }
    }
    return flow;
  }

private:
  void bfs(Vertex s) {
    import std.container : DList;

    foreach (v; vertices)
      v.level = -1;
    s.level = 0;
    auto list = DList!Vertex(s);
    while (!list.empty) {
      Vertex v = list.front;
      list.removeFront;
      foreach (e; v.edges) {
        if (e.capacity <= 0 || e.end.level >= 0)
          continue;
        e.end.level = e.start.level + 1;
        list.insertBack(e.end);
      }
    }
  }

  long dfs(Vertex v, Vertex t, long f) {
    if (v is t)
      return f;
    foreach (i; v.iter .. v.edges.length) {
      v.iter = i;
      Edge e = v.edges[i];
      if (e.capacity <= 0 || e.end.level <= e.start.level)
        continue;
      long d = dfs(e.end, t, min(f, e.capacity));
      if (d > 0) {
        e.capacity -= d;
        e.revEdge.capacity += d;
        return d;
      }
    }
    return 0;
  }

  class Vertex {
    long level;
    long iter;
    Edge[] edges;
  }

  class Edge {
    Vertex start, end;
    long initCapacity;
    long capacity;
    Edge revEdge;
    this(Vertex start, Vertex end, long capacity) {
      this.start = start;
      this.end = end;
      this.initCapacity = capacity;
    }
  }
}
