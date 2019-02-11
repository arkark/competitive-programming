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
import core.bitop : popcnt;
alias Generator = std.concurrency.Generator;

enum long INF = long.max/3;
enum long MOD = 10L^^9+7;

struct Pos {
  long index;
  Vector v;
  double angle;
  double length;
}

void main() {
  long N;
  scanln(N);
  Pos[] ps = new Pos[N];
  foreach(i; 0..N) {
    ps[i].index = i;
    scanln(ps[i].v.x, ps[i].v.y);
  }

  Vector center = Vector(0, 0);
  foreach(i; 0..N) {
    center = center + ps[i].v;
  }
  center = center / N;

  foreach(i; 0..N) {
    ps[i].v = ps[i].v - center;
  }

  foreach(i; 0..N) {
    ps[i].angle = atan2(ps[i].v.y, ps[i].v.x);
    ps[i].length = length(ps[i].v);
  }

  ps.sort!"a.angle < b.angle";

  void f() {
    double average = 0;
    foreach(i; 0..N) {
      average += dist(ps[i].v, ps[(i+1)%$].v);
    }
    average /= N;

    Pos[] qs = ps.dup.sort!"a.angle < b.angle".array;
    bool[] used = new bool[N];

    double len = average;
    long k = 0;
    foreach(i; 0..long.max) {
      if (k == N) break;
      len *= 2;
      foreach(j; 0..N) {
        if (used[qs[j].index]) continue;
        if (qs[j].length > len) continue;
        used[qs[j].index] = true;
        ps[k++] = qs[j];
      }
    }
  }

  foreach(_; 0..100) {
    f();
  }

  // or-opt?
  void g() {
    double average = 0;
    foreach(i; 0..N) {
      average += dist(ps[i].v, ps[(i+1)%$].v);
    }
    average /= N;

    foreach(i; 0..N) foreach(j; 0..N) {
      long i1 = i;
      long i2 = (i+1)%N;
      long j1 = j;
      long j2 = (j+1)%N;
      long j3 = (j+2)%N;
      if (j1==i2 || j1==i1 || j2==i1 || j3==i1) continue;

      double d1 = dist(ps[i1].v, ps[i2].v);
      double d2 = dist(ps[j1].v, ps[j2].v);
      double d3 = dist(ps[j2].v, ps[j3].v);
      double d4 = dist(ps[i1].v, ps[j2].v);
      double d5 = dist(ps[j2].v, ps[i2].v);
      double d6 = dist(ps[j1].v, ps[j3].v);
      double x1 = (
        abs(d1-average)^^2 + abs(d2-average)^^2 + abs(d3-average)^^2
      );
      double x2 = (
        abs(d4-average)^^2 + abs(d5-average)^^2 + abs(d6-average)^^2
      );
      if (x2 < x1) {
        Pos p = ps[j2];
        ps.insertInPlace(i2, p);
        foreach(k; 0..N) {
          if (k == i2) continue;
          if (ps[k].index == p.index) {
            ps = ps[0..k] ~ ps[k+1..$];
            break;
          }
        }
      }
    }
  }

  // 2-opt?
  void h() {
    double average = 0;
    foreach(i; 0..N) {
      average += dist(ps[i].v, ps[(i+1)%$].v);
    }
    average /= N;

    foreach(i; 0..N) foreach(j; 0..N) {
      long i1 = i;
      long i2 = (i+1)%N;
      long j1 = j;
      long j2 = (j+1)%N;
      if (j1==i1) continue;

      double d1 = dist(ps[i1].v, ps[i2].v);
      double d2 = dist(ps[j1].v, ps[j2].v);
      double d3 = dist(ps[i1].v, ps[j1].v);
      double d4 = dist(ps[i2].v, ps[j2].v);
      double x1 = (
        abs(d1-average)^^2 + abs(d2-average)^^2
      );
      double x2 = (
        abs(d3-average)^^2 + abs(d4-average)^^2
      );
      if (x2 < x1) {
        long l = i2;
        long r = j1;
        long l2 = -1;
        long r2 = -1;
        while(true) {
          if (l==r || l==r2 || r==l2) {
            break;
          }
          swap(ps[l], ps[r]);
          l2 = l;
          r2 = r;
          l = (l+1)%N;
          r = (r-1+N)%N;
        }
      }
    }
  }

  foreach(_; 0..100) {
    g();
    h();
  }

  foreach(i; 0..N) {
    ps[i].index.writeln;
  }
}

struct Vector {
    double x, y;
    Vector opBinary(string op)(Vector rhs) {
        mixin("return Vector(this.x"~op~"rhs.x, this.y"~op~"rhs.y);");
    }
    Vector opBinary(string op, T)(T rhs) {
        mixin("return Vector(this.x"~op~"rhs, this.y"~op~"rhs);");
    }
}

Vector mult(double a, Vector p) {
    return Vector(a*p.x, a*p.y);
}
double cross(Vector v1, Vector v2) {
    return v1.x*v2.y - v1.y*v2.x;
}
double dot(double z1, double z2) {
    return z1*z2;
}
double dot(Vector v1, Vector v2) {
    return v1.x*v2.x + v1.y*v2.y;
}
double distSq(Vector v1, Vector v2) {
    return (v2.x-v1.x)^^2 + (v2.y-v1.y)^^2;
}
double dist(Vector v1, Vector v2) {
    return sqrt(distSq(v1, v2));
}
double lengthSq(Vector v) {
  return v.x*v.x + v.y*v.y;
}
double length(Vector v) {
  return sqrt(lengthSq(v));
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
  if (t * y < x) t++;
  return t;
}

T floor(T)(T x, T y) if (isIntegral!T || is(T == BigInt)) {
  T t = x / y;
  if (t * y > x) t--;
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
  import std.meta;
  template getFormat(T) {
    static if (isIntegral!T) {
      enum getFormat = "%d";
    } else static if (isFloatingPoint!T) {
      enum getFormat = "%g";
    } else static if (isSomeString!T || isSomeChar!T) {
      enum getFormat = "%s";
    } else {
      static assert(false);
    }
  }
  enum string fmt = [staticMap!(getFormat, Args)].join(" ");
  string[] inputs = readln.chomp.split;
  foreach(i, ref v; args) {
    v = inputs[i].to!(Args[i]);
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

// cumulativeFold was added in D 2.072.0
static if (__VERSION__ < 2072) {
  template cumulativeFold(fun...)
  if (fun.length >= 1)
  {
    import std.meta : staticMap;
    private alias binfuns = staticMap!(binaryFun, fun);

    auto cumulativeFold(R)(R range)
    if (isInputRange!(Unqual!R))
    {
      return cumulativeFoldImpl(range);
    }

    auto cumulativeFold(R, S)(R range, S seed)
    if (isInputRange!(Unqual!R))
    {
      static if (fun.length == 1)
        return cumulativeFoldImpl(range, seed);
      else
        return cumulativeFoldImpl(range, seed.expand);
    }

    private auto cumulativeFoldImpl(R, Args...)(R range, ref Args args)
    {
      import std.algorithm.internal : algoFormat;

      static assert(Args.length == 0 || Args.length == fun.length,
        algoFormat("Seed %s does not have the correct amount of fields (should be %s)",
          Args.stringof, fun.length));

      static if (args.length)
        alias State = staticMap!(Unqual, Args);
      else
        alias State = staticMap!(ReduceSeedType!(ElementType!R), binfuns);

      foreach (i, f; binfuns)
      {
        static assert(!__traits(compiles, f(args[i], e)) || __traits(compiles,
            { args[i] = f(args[i], e); }()),
          algoFormat("Incompatible function/seed/element: %s/%s/%s",
            fullyQualifiedName!f, Args[i].stringof, E.stringof));
      }

      static struct Result
      {
      private:
        R source;
        State state;

        this(R range, ref Args args)
        {
          source = range;
          if (source.empty)
            return;

          foreach (i, f; binfuns)
          {
            static if (args.length)
              state[i] = f(args[i], source.front);
            else
              state[i] = source.front;
          }
        }

      public:
        @property bool empty()
        {
          return source.empty;
        }

        @property auto front()
        {
          assert(!empty, "Attempting to fetch the front of an empty cumulativeFold.");
          static if (fun.length > 1)
          {
            import std.typecons : tuple;
            return tuple(state);
          }
          else
          {
            return state[0];
          }
        }

        void popFront()
        {
          assert(!empty, "Attempting to popFront an empty cumulativeFold.");
          source.popFront;

          if (source.empty)
            return;

          foreach (i, f; binfuns)
            state[i] = f(state[i], source.front);
        }

        static if (isForwardRange!R)
        {
          @property auto save()
          {
            auto result = this;
            result.source = source.save;
            return result;
          }
        }

        static if (hasLength!R)
        {
          @property size_t length()
          {
            return source.length;
          }
        }
      }

      return Result(range, args);
    }
  }
}

// minElement/maxElement was added in D 2.072.0
static if (__VERSION__ < 2072) {
  private template RebindableOrUnqual(T)
  {
      static if (is(T == class) || is(T == interface) || isDynamicArray!T || isAssociativeArray!T)
          alias RebindableOrUnqual = Rebindable!T;
      else
          alias RebindableOrUnqual = Unqual!T;
  }
  private auto extremum(alias map, alias selector = "a < b", Range)(Range r)
  if (isInputRange!Range && !isInfinite!Range &&
      is(typeof(unaryFun!map(ElementType!(Range).init))))
  in
  {
      assert(!r.empty, "r is an empty range");
  }
  body
  {
      alias Element = ElementType!Range;
      RebindableOrUnqual!Element seed = r.front;
      r.popFront();
      return extremum!(map, selector)(r, seed);
  }

  private auto extremum(alias map, alias selector = "a < b", Range,
                        RangeElementType = ElementType!Range)
                       (Range r, RangeElementType seedElement)
  if (isInputRange!Range && !isInfinite!Range &&
      !is(CommonType!(ElementType!Range, RangeElementType) == void) &&
       is(typeof(unaryFun!map(ElementType!(Range).init))))
  {
      alias mapFun = unaryFun!map;
      alias selectorFun = binaryFun!selector;

      alias Element = ElementType!Range;
      alias CommonElement = CommonType!(Element, RangeElementType);
      RebindableOrUnqual!CommonElement extremeElement = seedElement;


      // if we only have one statement in the loop, it can be optimized a lot better
      static if (__traits(isSame, map, a => a))
      {

          // direct access via a random access range is faster
          static if (isRandomAccessRange!Range)
          {
              foreach (const i; 0 .. r.length)
              {
                  if (selectorFun(r[i], extremeElement))
                  {
                      extremeElement = r[i];
                  }
              }
          }
          else
          {
              while (!r.empty)
              {
                  if (selectorFun(r.front, extremeElement))
                  {
                      extremeElement = r.front;
                  }
                  r.popFront();
              }
          }
      }
      else
      {
          alias MapType = Unqual!(typeof(mapFun(CommonElement.init)));
          MapType extremeElementMapped = mapFun(extremeElement);

          // direct access via a random access range is faster
          static if (isRandomAccessRange!Range)
          {
              foreach (const i; 0 .. r.length)
              {
                  MapType mapElement = mapFun(r[i]);
                  if (selectorFun(mapElement, extremeElementMapped))
                  {
                      extremeElement = r[i];
                      extremeElementMapped = mapElement;
                  }
              }
          }
          else
          {
              while (!r.empty)
              {
                  MapType mapElement = mapFun(r.front);
                  if (selectorFun(mapElement, extremeElementMapped))
                  {
                      extremeElement = r.front;
                      extremeElementMapped = mapElement;
                  }
                  r.popFront();
              }
          }
      }
      return extremeElement;
  }

  private auto extremum(alias selector = "a < b", Range)(Range r)
  if (isInputRange!Range && !isInfinite!Range &&
      !is(typeof(unaryFun!selector(ElementType!(Range).init))))
  {
      return extremum!(a => a, selector)(r);
  }

  // if we only have one statement in the loop it can be optimized a lot better
  private auto extremum(alias selector = "a < b", Range,
                        RangeElementType = ElementType!Range)
                       (Range r, RangeElementType seedElement)
  if (isInputRange!Range && !isInfinite!Range &&
      !is(CommonType!(ElementType!Range, RangeElementType) == void) &&
      !is(typeof(unaryFun!selector(ElementType!(Range).init))))
  {
      return extremum!(a => a, selector)(r, seedElement);
  }

  auto minElement(alias map = (a => a), Range)(Range r)
  if (isInputRange!Range && !isInfinite!Range)
  {
      return extremum!map(r);
  }
  auto minElement(alias map = (a => a), Range, RangeElementType = ElementType!Range)
                 (Range r, RangeElementType seed)
  if (isInputRange!Range && !isInfinite!Range &&
      !is(CommonType!(ElementType!Range, RangeElementType) == void))
  {
      return extremum!map(r, seed);
  }
  auto maxElement(alias map = (a => a), Range)(Range r)
  if (isInputRange!Range && !isInfinite!Range)
  {
      return extremum!(map, "a > b")(r);
  }
  auto maxElement(alias map = (a => a), Range, RangeElementType = ElementType!Range)
                 (Range r, RangeElementType seed)
  if (isInputRange!Range && !isInfinite!Range &&
      !is(CommonType!(ElementType!Range, RangeElementType) == void))
  {
      return extremum!(map, "a > b")(r, seed);
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
