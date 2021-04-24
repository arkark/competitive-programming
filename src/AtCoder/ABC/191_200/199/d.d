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
  Vertex[] adj;
  long color = 0;
  long subIndex = -1;
  mixin Constructor;
}

void main() {
  long N, M;
  scanln(N, M);
  Vertex[] vs = N.iota.map!(i => new Vertex(i)).array;

  auto qf = QuickFind(N);
  foreach (i; 0 .. M) {
    long a, b;
    scanln(a, b);
    a--;
    b--;
    vs[a].adj ~= vs[b];
    vs[b].adj ~= vs[a];
    qf.unite(a, b);
  }

  long ans = 1;
  foreach (root; 0 .. N) {
    if (!qf.isRoot(root))
      continue;

    Vertex[] us = qf.getSet(root).map!(i => vs[i]).array;
    long K = us.length;

    if (K == 1) {
      ans *= 3;
      continue;
    }

    {
      long j = 0;
      foreach (i; 0 .. K) {
        if (us[i].index == root)
          continue;
        us[i].subIndex = j++;
      }
      vs[root].subIndex = j++;
      assert(j == K);
    }

    long res = 0;

    foreach (bits; 0 .. 1 << (K - 1)) {
      void rec(Vertex v) {
        foreach (u; v.adj) {
          if (u.color != -1)
            continue;

          long t = 1 + (bits >> u.subIndex & 1);
          u.color = (v.color + t) % 3;
          rec(u);
        }
      }

      foreach (u; us) {
        u.color = -1;
      }
      vs[root].color = 0;
      rec(vs[root]);

      bool ok = true;
      foreach (v; us) {
        foreach (u; v.adj) {
          ok &= v.color != u.color;
        }
      }
      if (ok) {
        res++;
      }
    }

    res *= 3;

    ans *= res;
  }

  ans.writeln;
}

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
