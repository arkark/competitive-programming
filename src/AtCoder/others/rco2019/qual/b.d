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

struct Query {
  long op;
  long x, y;
  long score;
  bool wrong = false;
}

long[] dx = [-1, 0, 1, 0];
long[] dy = [0, -1, 0, 1];

void main() {
  long N, M;
  scanln(N, M);
  long[][] vss = N.rep!(() => readln.split.to!(long[]));
  bool[][] used = new bool[][](N, N);

  Query[] ans = [];

  bool[][] flag = new bool[][](N, N);

  long recCount(long x, long y, long v) {
    if (x<0 || x>=N) return 0;
    if (y<0 || y>=N) return 0;
    if (used[x][y]) return 0;
    if (flag[x][y]) return 0;
    flag[x][y] = true;
    if (vss[x][y] != v) return 0;

    long res = 1;
    foreach(k; 0..4) {
      res += recCount(x+dx[k], y+dy[k], v);
    }
    return res;
  }

  long count(long x, long y) {
    long v = vss[x][y];
    foreach(i; 0..N) flag[i][] = false;
    return recCount(x, y, v);
  }

  void inc1(long x, long y, long diff) {
    long v = vss[x][y];
    long cnt = 0;
    foreach(k; 0..4) {
      if (x+dx[k]<0 || x+dx[k]>=N) continue;
      if (y+dy[k]<0 || y+dy[k]>=N) continue;
      long u = vss[x+dx[k]][y+dy[k]];
      if (u == v+diff) {
        cnt++;
      }
    }
    if (cnt >= 2) {
      vss[x][y] += diff;
      foreach(i; 0..diff) {
        ans ~= Query(1, x, y, 0);
      }
    }
  }

  void inc2(long x, long y, long diff) {
    long v = vss[x][y];
    // {
    //   long cnt = count(x, y);
    //   if (v >= cnt && v>=3) {
    //     return;
    //   }
    // }
    bool ok = false;
    foreach(k; 0..4) {
      if (x+dx[k]<0 || x+dx[k]>=N) continue;
      if (y+dy[k]<0 || y+dy[k]>=N) continue;
      long cnt = count(x+dx[k], y+dy[k]);
      long u = vss[x+dx[k]][y+dy[k]];
      if (cnt+1 == u && u==v+diff) {
        ok = true;
      }
    }
    if (ok) {
      vss[x][y] += diff;
      foreach(i; 0..diff) {
        ans ~= Query(1, x, y, 0);
      }
    }
  }

  bool canGet(long x, long y) {
    long v = vss[x][y];
    foreach(i; 0..N) flag[i][] = false;
    return recCount(x, y, v) >= v;
  }

  void get(long x, long y) {
    void rec(long x, long y, long v) {
      if (x<0 || x>=N) return;
      if (y<0 || y>=N) return;
      if (used[x][y]) return;
      if (flag[x][y]) return;
      flag[x][y] = true;
      if (vss[x][y] != v) return;

      used[x][y] = true;
      foreach(k; 0..4) {
        rec(x+dx[k], y+dy[k], v);
      }
    }

    long v = vss[x][y];
    long cnt = count(x, y);
    foreach(i; 0..N) flag[i][] = false;
    rec(x, y, v);
    ans ~= Query(2, x, y, v*cnt);
  }

  void f1(long diff) {
    foreach(i; 0..N) foreach(j; 0..N) {
      inc1(i, j, diff);
    }
  }
  void f2(long diff) {
    foreach(i; 0..N) foreach(j; 0..N) {
      inc2(i, j, diff);
    }
  }
  void g() {
    foreach(i; 0..N) foreach(j; 0..N) {
      if (canGet(i, j)) {
        get(i, j);
      }
    }
  }


  foreach(diff; 1..6+1) {
    foreach(i; 0..10) {
      f2(diff);
      f2(1);
    }
  }

  foreach(diff; 1..5+1) {
    foreach(i; 0..10) {
      f1(diff);
      f1(1);
    }
  }
  foreach(diff; 1..2+1) {
    foreach(i; 0..10) {
      f2(diff);
      f1(diff);
    }
    foreach(i; 0..2) {
      f2(1);
      f1(1);
    }
  }


  g();

  ans.sort!(
    (a, b) => a.op!=b.op ? a.op<b.op : a.score>b.score
  );

  foreach(i; 0..ans.length) {
    if (used[ans[i].x][ans[i].y]) continue;
    ans[i].wrong = true;
  }

  long k = 0;
  foreach(i; 0..ans.length) {
    if (k >= M) break;
    if (ans[i].wrong) continue;
    writeln(ans[i].op, " ", ans[i].x, " ", ans[i].y);
    k++;
  }

  // ans.filter!"!a.wrong".count.writeln;
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
