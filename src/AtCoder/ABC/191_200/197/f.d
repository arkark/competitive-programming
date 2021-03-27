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

class Vertex {
  long index;
  Edge[] edges;
  mixin Constructor;
}

struct Edge {
  Vertex toV;
  long c;
}

void main() {
  long N, M;
  scanln(N, M);
  long K = 26;

  Vertex[] vs = N.iota.map!(i => new Vertex(i)).array;
  foreach (i; 0 .. M) {
    long a, b;
    char c2;
    scanln(a, b, c2);
    a--;
    b--;
    long c = (c2 - 'a').to!long;
    vs[a].edges ~= Edge(vs[b], c);
    vs[b].edges ~= Edge(vs[a], c);
  }

  struct P {
    Vertex v1, v2;
    long d;
  }

  long id(long x, long y) {
    if (x > y)
      swap(x, y);
    return x * N + y;
  }

  long[] ds = new long[N * N];
  ds[] = INF;

  auto tree = redBlackTree!(
      "a.d != b.d ? a.d < b.d : a.v1.index != b.v1.index ? a.v1.index < b.v1.index : a.v2.index < b.v2.index",
      true,
      P,
  )(P(vs[0], vs[N - 1], 0));
  ds[id(0, N - 1)] = 0;

  long ans = INF;

  while (!tree.empty) {
    P p = tree.front;
    tree.removeFront;

    if (p.d > ans) {
      break;
    }
    if (p.d > 3 * N) {
      break;
    }

    if (p.d > ds[id(p.v1.index, p.v2.index)]) {
      continue;
    }

    if (p.v1.index == p.v2.index) {
      ans.ch!min(p.d);
      break;
    }

    Vertex v1 = p.v1;
    Vertex v2 = p.v2;
    if (v1.edges.length > v2.edges.length) {
      swap(v1, v2);
    }
    bool exists = false;
    foreach (e1; v1.edges) {
      if (e1.toV.index == v2.index) {
        ans.ch!min(p.d + 1);
        exists = true;
      }
    }
    if (exists)
      continue;

    foreach (e1; v1.edges) {
      foreach (e2; v2.edges) {
        if (e1.c == e2.c) {
          long d2 = p.d + 2;
          if (d2 < ds[id(e1.toV.index, e2.toV.index)]) {
            ds[id(e1.toV.index, e2.toV.index)] = d2;
            P p2 = P(e1.toV, e2.toV, d2);
            tree.insert(p2);
          }
        }
      }
    }
  }
  if (ans < INF) {
    writeln(ans);
  } else {
    writeln(-1);
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
