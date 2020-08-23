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

long setMax(ref long[long] aa, long k, long v) {
  if (k in aa) {
    aa[k].ch!max(v);
  } else {
    aa[k] = v;
  }
  return aa[k];
}

ref long get(long[][] tss, long x, long y) {
  if (x > y)
    swap(x, y);
  return tss[x][y];
}

void main() {
  long N;
  scanln(N);
  long[] as = readln.split
    .to!(long[])
    .map!"a-1"
    .array;

  long key(long x, long y) {
    if (x > y)
      swap(x, y);
    return x * N + y;
  }

  long[][] tss = new long[][](N, N);
  foreach (i; 0 .. N)
    tss[i][] = -1;
  tss.get(as[0], as[1]) = 0;

  long maxV = 0;
  long[] maxVs = new long[N];
  maxVs[] = -1;
  maxVs[as[0]] = 0;
  maxVs[as[1]] = 0;

  long[long] aa;

  long cnt = 0;

  foreach (d; 0 .. N - 1) {
    aa = null;

    long[] xs = as[3 * d + 2 .. 3 * d + 5];
    xs.sort!"a<b";

    foreach (i, x; xs) {
      long y = xs[(i + 1) % 3];
      long z = xs[(i + 2) % 3];
      // use x
      aa.setMax(key(y, z), maxV);
      if (tss.get(x, x) >= 0) {
        aa.setMax(key(y, z), tss.get(x, x) + 1);
      }
    }

    foreach (perm; 3.iota.permutations) {
      if (perm[0] > perm[1])
        continue;
      long x = xs[perm[0]];
      long y = xs[perm[1]];
      long z = xs[perm[2]];
      // use x, y
      foreach (a; 0 .. N) {
        if (maxVs[a] < 0)
          continue;
        aa.setMax(key(a, z), maxVs[a]);
      }
      if (x == y) {
        foreach (a; 0 .. N) {
          if (tss.get(a, x) >= 0) {
            aa.setMax(key(a, z), tss.get(a, x) + 1);
          }
        }
      }
    }

    // aa.byKeyValue.map!(a => format!"(%s, %s, %s)"(a.key / N, a.key % N, a.value)).join(", ")
    //   .writeln;

    if (xs[0] == xs[1] && xs[1] == xs[2]) {
      cnt++;
    }

    foreach (k, v; aa) {
      long u = v;
      if (xs[0] == xs[1] && xs[1] == xs[2]) {
        u--;
      }
      maxV.ch!max(tss.get(k / N, k % N).ch!max(u));
      maxVs[k / N].ch!max(u);
      maxVs[k % N].ch!max(u);
    }

  }

  foreach (x; 0 .. N)
    foreach (y; 0 .. N) {
      long z = as.back;
      if (tss[x][y] < 0)
        continue;
      if (x == y && y == z) {
        tss[x][y]++;
      }
    }

  long ans = 0;
  foreach (x; 0 .. N)
    foreach (y; 0 .. N) {
      if (tss[x][y] < 0)
        continue;
      ans.ch!max(tss[x][y] + cnt);
    }

  ans.writeln;
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
