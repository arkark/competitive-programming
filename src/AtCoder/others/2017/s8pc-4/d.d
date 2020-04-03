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
  long N;
  scanln(N);

  struct M {
    double p;
    long num;
  }

  auto tree = Rerooting!(
    M, bool,
    (a, b) => M(
      a.p + b.p,
      a.num + b.num,
    ),
    (a, _) => M(
      1 + (a.num == 0 ? 0 : a.p / a.num),
      1,
    ),
    M(0, 0),
  )(N);

  foreach(i; 0..N-1) {
    long u, v;
    scanln(u, v);
    u--; v--;
    tree.addEdge(u, v);
  }

  foreach(m; tree.solve) {
    writefln("%0.8f", m.p - 1);
  }
}

template Rerooting(
  M,              // DPの要素の型
  X,              // 各頂点がもつ値の型
  alias fun,      // DPの要素間の2項演算
  alias afterFun, // 頂点の値からDPの要素への作用
  M identity,     // DPの要素の単位元
  bool ctfeCheckActive = true,
) {
  import std.algorithm : map;
  import std.array : array;
  import std.functional : binaryFun;

  static if (ctfeCheckActive) {
    static assert(is(typeof(binaryFun!fun(identity, identity)) : M));
    static assert(is(typeof(binaryFun!afterFun(identity, X.init)) : M));
    static assert(binaryFun!fun(identity, identity) == identity);
  }

  struct Rerooting {

  private:
    alias _fun = binaryFun!fun;
    alias _afterFun = binaryFun!afterFun;

    Vertex[] _vertices;

  public:
    // O(n)
    this(size_t n) {
      _vertices.length = n;
      foreach(i; 0..n) {
        _vertices[i] = new Vertex(X.init);
      }
    }

    // O(n)
    this(X[] values) {
      _vertices = values.map!(
        value => new Vertex(value)
      ).array;
    }

    size_t size() {
      return _vertices.length;
    }

    void addEdge(size_t x, size_t y) {
      _vertices[x].adj ~= _vertices[y];
      _vertices[y].adj ~= _vertices[x];
    }

    M[] solve(size_t rootIndex = 0) in {
      assert(rootIndex < size);
    } body {
      Vertex[] vs = getOrderedVertices(rootIndex);

      foreach_reverse(v; vs) {
        M acc = identity;
        foreach(u; v.adj) {
          if (u is v.parent) continue;
          acc = _fun(acc, u.dpValue);
        }
        acc = _afterFun(acc, v.value);
        v.dpValue = acc;
      }

      M[] accL = new M[size];
      M[] accR = new M[size];
      foreach(v; vs) {
        size_t len = v.adj.length;
        assert(len+1 <= size);
        accL[0] = identity;
        accR[len] = identity;
        foreach(j, u; v.adj) {
          accL[j+1] = _fun(
            accL[j],
            u is v.parent ? v.parentDpValue : u.dpValue
          );
        }
        foreach_reverse(j, u; v.adj) {
          accR[j] = _fun(
            u is v.parent ? v.parentDpValue : u.dpValue,
            accR[j+1]
          );
        }
        assert(accL[len] == accR[0]);
        v.dpValue = _afterFun(accL[len], v.value);

        foreach(j, u; v.adj) {
          if (u is v.parent) continue;
          u.parentDpValue = _afterFun(
            _fun(accL[j], accR[j+1]),
            v.value
          );
        }
      }

      return _vertices.map!"a.dpValue".array;
    }

  private:
    class Vertex {
      X value;
      M dpValue;
      Vertex[] adj;
      Vertex parent;
      M parentDpValue;
      this(X value) {
        this.value = value;
      }
    }

    Vertex[] getOrderedVertices(size_t rootIndex) {
      Vertex[] vs = new Vertex[size];
      size_t index = 0;

      auto stack = DList!Vertex(_vertices[rootIndex]);
      while(!stack.empty) {
        Vertex v = stack.back;
        stack.removeBack;
        vs[index++] = v;
        foreach(u; v.adj) {
          if (u is v.parent) continue;
          u.parent = v;
          stack.insertBack(u);
        }
      }
      assert(index == size);

      return vs;
    }
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

void scanln(Args...)(auto ref Args args) {
  enum sep = " ";
  enum n = Args.length;
  enum fmt = n.rep!(()=>"%s").join(sep);

  string line = readln.chomp;
  static if (__VERSION__ >= 2074) {
    line.formattedRead!fmt(args);
  } else {
    enum argsTemp = n.iota.map!(
      i => "&args[%d]".format(i)
    ).join(", ");
    mixin(
      "line.formattedRead(fmt, " ~ argsTemp ~ ");"
    );
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
