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
  long N, Q;
  scanln(N, Q);
  auto dsu = Dsu(N);

  foreach (i; 0 .. Q) {
    long t, u, v;
    scanln(t, u, v);
    if (t == 0) {
      dsu.merge(u, v);
    } else {
      writeln(dsu.same(u, v) ? 1 : 0);
    }
  }
}

// Implement (union by size) + (path compression)
// Reference:
// Zvi Galil and Giuseppe F. Italiano,
// Data structures and algorithms for disjoint set union problems
struct Dsu {
  import std.algorithm : swap, filter;
  import std.array : array;

private:
  long _n;

  // root node: -1 * component size
  // otherwise: parent
  long[] parentOrSize;

public:
  this(long n) {
    _n = n;
    parentOrSize = new long[n];
    parentOrSize[] = -1;
  }

  long merge(long a, long b)
  in (0 <= a && a < _n)
  in (0 <= b && b < _n) {
    long x = leader(a);
    long y = leader(b);
    if (x == y)
      return x;
    if (-parentOrSize[x] < -parentOrSize[y])
      swap(x, y);
    parentOrSize[x] += parentOrSize[y];
    parentOrSize[y] = x;
    return x;
  }

  bool same(long a, long b)
  in (0 <= a && a < _n)
  in (0 <= b && b < _n) {
    return leader(a) == leader(b);
  }

  long leader(long a)
  in (0 <= a && a < _n) {
    if (parentOrSize[a] < 0) {
      return a;
    } else {
      return parentOrSize[a] = leader(parentOrSize[a]);
    }
  }

  long size(long a)
  in (0 <= a && a < _n) {
    return -parentOrSize[leader(a)];
  }

  long[][] groups() {
    long[] leaderBuf = new long[_n];
    long[] groupSize = new long[_n];
    foreach (i; 0 .. _n) {
      leaderBuf[i] = leader(i);
      groupSize[leaderBuf[i]]++;
    }
    long[][] result = new long[][_n];
    foreach (i; 0 .. _n) {
      result[i].reserve(groupSize[i]);
    }
    foreach (i; 0 .. _n) {
      result[leaderBuf[i]] ~= i;
    }
    return result.filter!"!a.empty".array;
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
