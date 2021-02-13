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

struct Sub {
  long num;
  long diff;
}

class Vertex {
  long index;
  Vertex[] children;
  mixin Constructor;
}

void main() {
  long N;
  scanln(N);
  Vertex[] vs = N.iota.map!(i => new Vertex(i)).array;
  {
    long[] ps = readln.split
      .to!(long[])
      .map!"a-1"
      .array;
    foreach (_i, p; ps) {
      long i = _i + 1;
      vs[p].children ~= vs[i];
    }
  }

  Sub rec(Vertex v) {
    Sub s = Sub(1, 1);

    Sub[] ts = v.children.map!rec.array;
    Sub[] evens1 = ts.filter!(t => t.num % 2 == 0 && t.diff >= 0).array;
    Sub[] evens2 = ts.filter!(t => t.num % 2 == 0 && t.diff < 0).array;
    Sub[] odds = ts.filter!(t => t.num % 2 == 1)
      .array
      .sort!"a.diff < b.diff"
      .array;

    long turn = 0;
    void add(Sub t) {
      s.num += t.num;
      if (turn % 2 == 0) {
        s.diff += t.diff;
      } else {
        s.diff -= t.diff;
      }
    }

    foreach (t; evens2) {
      add(t);
    }
    foreach (t; odds) {
      add(t);
      turn++;
    }
    foreach (t; evens1) {
      add(t);
    }

    return s;
  }

  Sub s = rec(vs[0]);
  assert(s.num == N);
  writeln((N + s.diff) / 2);
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
