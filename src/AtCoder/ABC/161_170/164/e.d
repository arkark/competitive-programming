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

enum long INF = long.max/5;

void main() {
  long N, M, S;
  scanln(N, M, S);

  long K = 50*(N-1);

  auto solver = Dijkstra!long(N*(K+1));

  struct P {
    long u, v, a, b;
  }
  struct Q {
    long c, d;
  }
  P[] ps = new P[M];
  Q[] qs = new Q[N];
  foreach(i; 0..M) {
    scanln(ps[i]);
    ps[i].u--;
    ps[i].v--;
  }
  foreach(i; 0..N) {
    scanln(qs[i]);
  }

  foreach(i; 1..min(S, K)+1) {
    long j = 0;
    long s = 0*N + j;
    long t = i*N + j;
    solver.addEdge(s, t, 0);
  }
  foreach(i; 0..K) {
    foreach(j; 0..N) {
      long s = i*N + j;
      long t = (i + qs[j].c)*N + j;
      if (t >= N*(K+1)) continue;
      solver.addEdge(s, t, qs[j].d);
    }
  }
  foreach(i; 0..K+1) {
    foreach(p; ps) {
      {
        long s = i*N + p.u;
        long t = (i - p.a)*N + p.v;
        if (t < 0) continue;
        solver.addEdge(s, t, p.b);
      }
      {
        long s = i*N + p.v;
        long t = (i - p.a)*N + p.u;
        if (t < 0) continue;
        solver.addEdge(s, t, p.b);
      }
    }
  }

  long[] xs = solver.solve(0);

  foreach(j; 1..N) {
    long ans = INF;
    foreach(i; 0..K+1) {
      ans.ch!min(xs[i*N + j]);
    }
    ans.writeln;
  }
}

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


// ----------------------------------------------


void times(alias fun)(long n) {
  // n.iota.each!(i => fun());
  foreach(i; 0..n) fun();
}
auto rep(alias fun, T = typeof(fun()))(long n) {
  // return n.iota.map!(i => fun()).array;
  T[] res = new T[n];
  foreach(ref e; res) e = fun();
  return res;
}

T ceil(T)(T x, T y) if (isIntegral!T || is(T == BigInt)) {
  // `(x+y-1)/y` will only work for positive numbers ...
  T t = x / y;
  if (y > 0 && t * y < x) t++;
  if (y < 0 && t * y > x) t++;
  return t;
}

T floor(T)(T x, T y) if (isIntegral!T || is(T == BigInt)) {
  T t = x / y;
  if (y > 0 && t * y > x) t--;
  if (y < 0 && t * y < x) t--;
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
    foreach(i, v; args) {
      mixin("this." ~ FieldNameTuple!(typeof(this))[i]) = v;
    }
  }
}

template scanln(Args...) {
  enum sep = " ";

  enum n = (){
    long n = 0;
    foreach(Arg; Args) {
      static if (is(Arg == class) || is(Arg == struct) || is(Arg == union)) {
        n += Fields!Arg.length;
      } else {
        n++;
      }
    }
    return n;
  }();

  enum fmt = n.rep!(()=>"%s").join(sep);

  enum argsString = (){
    string[] xs = [];
    foreach(i, Arg; Args) {
      static if (is(Arg == class) || is(Arg == struct) || is(Arg == union)) {
        foreach(T; FieldNameTuple!Arg) {
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
    x = (x & 0x5555555555555555L) + (x>> 1 & 0x5555555555555555L);
    x = (x & 0x3333333333333333L) + (x>> 2 & 0x3333333333333333L);
    x = (x & 0x0f0f0f0f0f0f0f0fL) + (x>> 4 & 0x0f0f0f0f0f0f0f0fL);
    x = (x & 0x00ff00ff00ff00ffL) + (x>> 8 & 0x00ff00ff00ff00ffL);
    x = (x & 0x0000ffff0000ffffL) + (x>>16 & 0x0000ffff0000ffffL);
    x = (x & 0x00000000ffffffffL) + (x>>32 & 0x00000000ffffffffL);
    return x;
  }
}
