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

uint N;
uint K;

struct T {
  long w, h;
  bool[][] xss;
  Polyomino ps;
  ulong getBits(long x, long y) {
    ulong bits = 0;
    foreach(p; ps) {
      assert((x + p.x) + (y + p.y)*N < 64);
      bits |= 1UL<<((x + p.x) + (y + p.y)*N);
    }
    return bits;
  }
}


void main() {
  scanln(N);
  scanln(K);

  bool[][] yss = N.rep!(() => readln.chomp.map!"a=='#'".array);

  T f(Polyomino ps) {
    long minX = ps.map!"a.x".reduce!min;
    long minY = ps.map!"a.y".reduce!min;
    ps = ps.map!(p => Point(p.x - minX, p.y - minY)).array;
    long w = ps.map!"a.x".reduce!max + 1;
    long h = ps.map!"a.y".reduce!max + 1;

    bool[][] xss = new bool[][](w, h);
    foreach(p; ps) {
      xss[p.x][p.y] = true;
    }
    return T(w, h, xss, ps);
  }

  bool[ulong] aa;
  long ans = 0;

  foreach(const poly; K.rank) {
    T[] ts = [
      f(poly.dup),
      f(poly.map!rotate90.array),
      f(poly.map!rotate180.array),
      f(poly.map!rotate270.array),
      f(poly.map!reflect.array.dup),
      f(poly.map!reflect.array.map!rotate90.array),
      f(poly.map!reflect.array.map!rotate180.array),
      f(poly.map!reflect.array.map!rotate270.array),
    ];
    foreach(t; ts) {
      foreach(x; 0..N.to!long-t.w+1) {
        foreach(y; 0..N.to!long-t.h+1) {
          ulong bits = t.getBits(x, y);
          if (bits in aa) continue;
          aa[bits] = true;

          bool ok = true;
          foreach(i; 0..t.w) {
            foreach(j; 0..t.h) {
              if (!t.xss[i][j]) continue;
              long x2 = x + i;
              long y2 = y + j;
              ok &= !yss[x2][y2];
            }
          }
          if(ok) {
            ans++;
          }
        }
      }
    }
  }
  ans.writeln;
}

// ----------------------------------------------

// From: https://rosettacode.org/wiki/Free_polyominoes_enumeration#D

alias Coord = long;
alias Point = Tuple!(Coord,"x", Coord,"y");
alias Polyomino = Point[];

/// Finds the min x and y coordiate of a Polyomino.
enum minima = (in Polyomino poly) pure @safe =>
    Point(poly.map!q{ a.x }.reduce!min, poly.map!q{ a.y }.reduce!min);

Polyomino translateToOrigin(in Polyomino poly) {
    const minP = poly.minima;
    return poly.map!(p => Point(cast(Coord)(p.x - minP.x), cast(Coord)(p.y - minP.y))).array;
}

enum Point function(in Point p) pure nothrow @safe @nogc
    rotate90  = p => Point( p.y, -p.x),
    rotate180 = p => Point(-p.x, -p.y),
    rotate270 = p => Point(-p.y,  p.x),
    reflect   = p => Point(-p.x,  p.y);

/// All the plane symmetries of a rectangular region.
auto rotationsAndReflections(in Polyomino poly) pure nothrow {
    return only(poly,
                poly.map!rotate90.array,
                poly.map!rotate180.array,
                poly.map!rotate270.array,
                poly.map!reflect.array,
                poly.map!(pt => pt.rotate90.reflect).array,
                poly.map!(pt => pt.rotate180.reflect).array,
                poly.map!(pt => pt.rotate270.reflect).array);
}

enum canonical = (in Polyomino poly) =>
    poly.rotationsAndReflections.map!(pl => pl.translateToOrigin.sort().release).reduce!min;

auto unique(T)(T[] seq) pure nothrow {
    return seq.sort().uniq;
}

/// All four points in Von Neumann neighborhood.
enum contiguous = (in Point pt) pure nothrow @safe @nogc =>
    only(Point(cast(Coord)(pt.x - 1), pt.y), Point(cast(Coord)(pt.x + 1), pt.y),
         Point(pt.x, cast(Coord)(pt.y - 1)), Point(pt.x, cast(Coord)(pt.y + 1)));

/// Finds all distinct points that can be added to a Polyomino.
enum newPoints = (in Polyomino poly) nothrow =>
    poly.map!contiguous.joiner.filter!(pt => !poly.canFind(pt)).array.unique;

enum newPolys = (in Polyomino poly) =>
    poly.newPoints.map!(pt => canonical(poly ~ pt)).array.unique;

/// Generates polyominoes of rank n recursively.
Polyomino[] rank(in uint n) {
    static immutable Polyomino monomino = [Point(0, 0)];
    static Polyomino[] monominoes = [monomino]; // Mutable.
    if (n == 0) return [];
    if (n == 1) return monominoes;
    return rank(n - 1).map!newPolys.join.unique.array;
}

/// Generates a textual representation of a Polyomino.
char[][] textRepresentation(in Polyomino poly) pure @safe {
    immutable minPt = poly.minima;
    immutable maxPt = Point(poly.map!q{ a.x }.reduce!max, poly.map!q{ a.y }.reduce!max);
    auto table = new char[][](maxPt.y - minPt.y + 1, maxPt.x - minPt.x + 1);
    foreach (row; table)
        row[] = ' ';
    foreach (immutable pt; poly)
        table[pt.y - minPt.y][pt.x - minPt.x] = '#';
    return table;
}

// ----------------------------------------------------------------------

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
