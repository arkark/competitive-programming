import std.stdio;
import std.string;
import std.format;
import std.conv;
import std.typecons;
import std.algorithm;
import std.functional;
import std.bigint;
import std.numeric;
import std.array;
import std.math;
import std.range;
import std.container;
import std.concurrency;
import std.traits;
import std.uni;
import std.regex;
import core.bitop : popcnt;

alias Generator = std.concurrency.Generator;

enum long INF = long.max / 5;

void main() {
  long N;
  scanln(N);

  struct P {
    long x, c;
  }

  P[] ps = new P[N];
  foreach (i; 0 .. N) {
    scanln(ps[i]);
  }

  ps.sort!"a.c < b.c";

  struct Q {
    long l, r;
    long c;
  }

  Q[] qs = [Q(0, 0, 0)];
  {
    long li = 0;
    foreach (i, p; ps) {
      if (i == N - 1 || ps[i + 1].c != p.c) {
        long ri = i;
        Q q;
        q.l = ps[li .. ri + 1].map!"a.x"
          .reduce!min;
        q.r = ps[li .. ri + 1].map!"a.x"
          .reduce!max;
        q.c = p.c;
        qs ~= q;

        li = ri + 1;
      }
    }
  }
  qs ~= Q(0, 0, long.max);

  long K = qs.length;

  long f(long x, long y1, long y2) {
    return abs(x - y1) + abs(y1 - y2);
  }

  auto solver = Dijkstra!long(2 * K);
  foreach (i; 0 .. K - 1) {
    solver.addEdge(
        i * 2 + 0, (i + 1) * 2 + 0, f(qs[i].l, qs[i + 1].r, qs[i + 1].l)
    );
    solver.addEdge(
        i * 2 + 0, (i + 1) * 2 + 1, f(qs[i].l, qs[i + 1].l, qs[i + 1].r)
    );
    solver.addEdge(
        i * 2 + 1, (i + 1) * 2 + 0, f(qs[i].r, qs[i + 1].r, qs[i + 1].l)
    );
    solver.addEdge(
        i * 2 + 1, (i + 1) * 2 + 1, f(qs[i].r, qs[i + 1].l, qs[i + 1].r)
    );
  }
  solver.addEdge(0 * 2 + 0, 0 * 2 + 1, 0);
  solver.addEdge((K - 1) * 2 + 0, (K - 1) * 2 + 1, 0);

  solver.solve(0)[(K - 1) * 2 + 1].writeln;
}

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

// ----------------------------------------------

void times(alias fun)(long n) {
  // n.iota.each!(i => fun());
  foreach (i; 0 .. n)
    fun();
}

auto rep(alias fun, T = typeof(fun()))(long n) {
  // return n.iota.map!(i => fun()).array;
  T[] res = new T[n];
  foreach (ref e; res)
    e = fun();
  return res;
}

T ceil(T)(T x, T y) if (isIntegral!T || is(T == BigInt)) {
  // `(x+y-1)/y` will only work for positive numbers ...
  T t = x / y;
  if (y > 0 && t * y < x)
    t++;
  if (y < 0 && t * y > x)
    t++;
  return t;
}

T floor(T)(T x, T y) if (isIntegral!T || is(T == BigInt)) {
  T t = x / y;
  if (y > 0 && t * y > x)
    t--;
  if (y < 0 && t * y < x)
    t--;
  return t;
}

ref T ch(alias fun, T, S...)(ref T lhs, S rhs) {
  return lhs = fun(lhs, rhs);
}

unittest {
  long x = 1000;
  x.ch!min(2000);
  assert(x == 1000);
  x.ch!min(3, 2, 1);
  assert(x == 1);
  x.ch!max(100).ch!min(1000); // clamp
  assert(x == 100);
  x.ch!max(0).ch!min(10); // clamp
  assert(x == 10);
}

mixin template Constructor() {
  import std.traits : FieldNameTuple;

  this(Args...)(Args args) {
    // static foreach(i, v; args) {
    foreach (i, v; args) {
      mixin("this." ~ FieldNameTuple!(typeof(this))[i]) = v;
    }
  }
}

template scanln(Args...) {
  enum sep = " ";

  enum n = () {
    long n = 0;
    foreach (Arg; Args) {
      static if (is(Arg == class) || is(Arg == struct) || is(Arg == union)) {
        n += Fields!Arg.length;
      } else {
        n++;
      }
    }
    return n;
  }();

  enum fmt = n.rep!(() => "%s").join(sep);

  enum argsString = () {
    string[] xs = [];
    foreach (i, Arg; Args) {
      static if (is(Arg == class) || is(Arg == struct) || is(Arg == union)) {
        foreach (T; FieldNameTuple!Arg) {
          xs ~= "&args[%d].%s".format(i, T);
        }
      } else {
        xs ~= "&args[%d]".format(i);
      }
    }
    return xs.join(", ");
  }();

  void scanln(auto ref Args args) {
    string line = readln.chomp;
    static if (__VERSION__ >= 2074) {
      mixin(
          "line.formattedRead!fmt(%s);".format(argsString)
      );
    } else {
      mixin(
          "line.formattedRead(fmt, %s);".format(argsString)
      );
    }
  }
}

// fold was added in D 2.071.0
static if (__VERSION__ < 2071) {
  template fold(fun...) if (fun.length >= 1) {
    auto fold(R, S...)(R r, S seed) {
      static if (S.length < 2) {
        return reduce!fun(seed, r);
      } else {
        return reduce!fun(tuple(seed), r);
      }
    }
  }
}

// popcnt with ulongs was added in D 2.071.0
static if (__VERSION__ < 2071) {
  ulong popcnt(ulong x) {
    x = (x & 0x5555555555555555L) + (x >> 1 & 0x5555555555555555L);
    x = (x & 0x3333333333333333L) + (x >> 2 & 0x3333333333333333L);
    x = (x & 0x0f0f0f0f0f0f0f0fL) + (x >> 4 & 0x0f0f0f0f0f0f0f0fL);
    x = (x & 0x00ff00ff00ff00ffL) + (x >> 8 & 0x00ff00ff00ff00ffL);
    x = (x & 0x0000ffff0000ffffL) + (x >> 16 & 0x0000ffff0000ffffL);
    x = (x & 0x00000000ffffffffL) + (x >> 32 & 0x00000000ffffffffL);
    return x;
  }
}
