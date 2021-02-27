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

import std.typecons : Tuple, tuple;
import std.numeric : gcd;

// @return: gcd(a, b)
// @side x, y:
//   s.t. ax + by = gcd(a, b)
long extgcd(long a, long b, ref long x, ref long y) {
  long g = a;
  if (b != 0) {
    g = extgcd(b, a % b, y, x);
    y -= (a / b) * x;
  } else {
    x = 1;
    y = 0;
  }
  return g;
}

// @return: a^-1 mod m
// @assert: gcd(a, m) = 1
long inverseMod(long a, long m)
in {
  assert(gcd(a, m) == 1);
}
body {
  long x, y;
  extgcd(a, m, x, y);
  return (x % m + m) % m;
}

// Solve 連立線形合同式
// @return x, m:
//   s.t. ∀i, as[i] * x = bs[i] mod ms[i]
//        m = lcm(ms[0..$])
//        0 ≦ x < m
Tuple!(long, "x", long, "m") chineseRemainderTheorem(long[] as, long[] bs, long[] ms)
in {
  assert(as.length == bs.length);
  assert(as.length == ms.length);
}
body {
  auto result = tuple!("x", "m")(0L, 1L);
  foreach (i; 0 .. as.length) {
    long s = as[i] * result.m;
    long t = bs[i] - as[i] * result.x;
    long d = gcd(ms[i], s);
    if (t % d != 0) {
      return tuple!("x", "m")(-1L, -1L); // not found
    }
    long u = t / d * inverseMod(s / d, ms[i] / d) % (ms[i] / d);
    result.x += result.m * u;
    result.m *= ms[i] / d;
    result.x = (result.x % result.m + result.m) % result.m;
  }
  return result;
}

long solve(long X, long Y, long P, long Q) {
  long res = INF;
  foreach (q; 0 .. Q) {
    foreach (y; 0 .. Y) {
      long[] as = [1, 1];
      long[] bs = [X + y, P + q];
      long[] ms = [2 * X + 2 * Y, P + Q];

      auto t = chineseRemainderTheorem(as, bs, ms);
      if (t.x < 0)
        continue;

      res.ch!min(t.x);
    }
  }
  return res;
}

void main() {
  long T;
  scanln(T);
  foreach (i; 0 .. T) {
    long X, Y, P, Q;
    scanln(X, Y, P, Q);
    long ans = solve(X, Y, P, Q);
    if (ans >= INF || ans < 0) {
      writeln("infinity");
    } else {
      ans.writeln;
    }
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
