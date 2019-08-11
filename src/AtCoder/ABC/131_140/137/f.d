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
import std.complex;
alias Generator = std.concurrency.Generator;

enum long INF = long.max/5;
enum long MOD = 10L^^9+7;

void main() {
  long p;
  scanln(p);
  long[] as = readln.split.to!(long[]);

  long[] bs = as.enumerate.filter!"a[1]==0".map!"a[0]".map!(to!long).array;
  long[] f(long left, long right) {
    assert(left < right);
    if (left + 1 == right) {
      return [-bs[left], 1];
    } else {
      long mid = (left + right)/2;
      long[] xs = f(left, mid);
      long[] ys = f(mid, right);
      xs.mul(ys, p);
      return xs;
    }
  }
  long[] ys = bs.empty ? [1L] : f(0, bs.length);

  long[] xs = new long[p];
  xs.id(p);
  xs.mul(ys, p);
  xs.pow(p-1, p);
  xs.map!(to!string).join(" ").writeln;
}

void id(long[] as, long mod) {
  foreach(i, ref a; as) {
    a = i==0 ? 1 : 0;
  }
}

void mul(ref long[] as, long[] bs, long mod) {
  long[] cs = Ntt.mul(as, bs, mod);
  long maxN = 1;
  foreach(i, c; cs) {
    auto j = i==0 ? i : (i-1)%(mod-1)+1;
    maxN.ch!max(j + 1);
  }
  as.length = maxN;
  as[] = 0;
  foreach(i, c; cs) {
    auto j = i==0 ? i : (i-1)%(mod-1)+1;
    as[j] = (as[j] + c) % mod;
  }
}

void pow(long[] as, long power, long mod) {
  static long[] bs;
  bs.length = mod;
  bs.id(mod);
  for(; power > 0; power >>= 1) {
    if (power & 1) {
      bs.mul(as, mod);
    }
    as.mul(as, mod);
  }
  as[] = bs[];
}

// Number Theoretic Transform (任意mod)
//   ref: https://satanic0258.github.io/snippets/math/NTT.html

/*
  long t = ...;
  long[] as = ...;
  long[] bs = ...;

  long[] cs = Ntt.mul(as, bs); // -> 多項式の積 as * bs mod t
*/
struct Ntt {
  private {
    enum long[] MOD_LIST = [1224736769, 469762049, 167772161];
    enum long[] PRIMITIVE_ROOT_LIST = [3, 3, 3];
    enum long NTT_CONVOLUTION_TIME = 3;
  }

  static long[] mul(long[] as, long[] bs, long mod) {
    as = as.dup;
    bs = bs.dup;
    foreach(ref a; as) a = ((a%mod) + mod)%mod;
    foreach(ref b; bs) b = ((b%mod) + mod)%mod;

    size_t m = as.length + bs.length - 1;
    size_t sz = 1;
    while(sz < m) sz <<= 1;
    as.length = sz;
    bs.length = sz;

    long[][] css = new long[][NTT_CONVOLUTION_TIME];
    if (NTT_CONVOLUTION_TIME >= 1) {
      css[0] = NttPart!(MOD_LIST[0], PRIMITIVE_ROOT_LIST[0]).mul(as, bs);
    }
    if (NTT_CONVOLUTION_TIME >= 2) {
      css[1] = NttPart!(MOD_LIST[1], PRIMITIVE_ROOT_LIST[1]).mul(as, bs);
    }
    if (NTT_CONVOLUTION_TIME >= 3) {
      css[2] = NttPart!(MOD_LIST[2], PRIMITIVE_ROOT_LIST[2]).mul(as, bs);
    }

    foreach(ref cs; css) {
      cs.length = m;
    }
    garner(css, mod);
    return css[0];
  }

  private static long powMod(long base, long power, long mod) {
    long res = 1;
    for(; power > 0; power >>= 1) {
      if (power & 1) {
        res = res * base % mod;
      }
      base = base * base % mod;
    }
    return res;
  }

  private static long invMod(long base, long mod) {
    return powMod(base, mod - 2, mod);
  }

  private static void garner(long[][] css, long mod) {
    size_t sz = css[0].length;
    static if (NTT_CONVOLUTION_TIME == 1) {
      foreach(ref c; css[0]) {
        c %= mod;
      }
    } else if (NTT_CONVOLUTION_TIME == 2) {
      enum long r01 = invMod(MOD_LIST[0], MOD_LIST[1]);
      foreach(i; 0..sz) {
        css[1][i] = (css[1][i] - css[0][i]) * r01 % MOD_LIST[1];
        if (css[1][i] < 0) css[1][i] += MOD_LIST[1];
        css[0][i] = (css[0][i] + css[1][i] * MOD_LIST[0]) % mod;
      }
    } else if (NTT_CONVOLUTION_TIME == 3) {
      enum long r01 = invMod(MOD_LIST[0], MOD_LIST[1]);
      enum long r02 = invMod(MOD_LIST[0], MOD_LIST[2]);
      enum long r12 = invMod(MOD_LIST[1], MOD_LIST[2]);
      long m01 = MOD_LIST[0] * MOD_LIST[1] % mod;
      foreach(i; 0..sz) {
        css[1][i] = (css[1][i] - css[0][i]) * r01 % MOD_LIST[1];
        if (css[1][i] < 0) css[1][i] += MOD_LIST[1];
        css[2][i] = ((css[2][i] - css[0][i]) * r02 % MOD_LIST[2] - css[1][i]) * r12 % MOD_LIST[2];
        if (css[2][i] < 0) css[2][i] += MOD_LIST[2];
        css[0][i] = (css[0][i] + css[1][i] * MOD_LIST[0] + css[2][i] * m01) % mod;
      }
    } else {
      assert(false);
    }
  }

  private struct NttPart(long mod, long primitiveRoot) {
    static long[] ntt(long[] as, bool inv = false) {
      as = as.dup;
      size_t sz = as.length;

      size_t mask = sz - 1;
      size_t p = 0;
      static long[] tmp;
      tmp.length = sz;
      for(size_t i = sz >> 1; i > 0; i >>= 1) {
        long[] cur = (p&1) ? tmp : as;
        long[] nex = (p&1) ? as : tmp;
        long e = powMod(primitiveRoot, (mod - 1)/sz*i, mod);
        if (inv) {
          e = invMod(e, mod);
        }
        long w = 1;
        for(size_t j = 0; j < sz; j += i) {
          foreach(k; 0..i) {
            nex[j + k] = (cur[(j<<1&mask) + k] + w * cur[(((j<<1) + i)&mask) + k]) % mod;
          }
          w = w * e % mod;
        }
        p++;
      }
      if (p&1) {
        swap(as, tmp);
      }
      if (inv) {
        long invSz = invMod(sz, mod);
        foreach(i; 0..sz) {
          as[i] = as[i] * invSz % mod;
        }
      }
      return as;
    }

    static long[] mul(long[] as, long[] bs) {
      as = ntt(as);
      bs = ntt(bs);
      size_t sz = as.length;
      foreach(i; 0..sz) {
        as[i] = as[i] * bs[i] % mod;
      }
      as = ntt(as, true);
      return as;
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
  enum sep = " ";
  enum n = Args.length;
  enum fmt = n.rep!(()=>"%s").join(sep) ~ "\n";
  static if (__VERSION__ >= 2071) {
    readf!fmt(args);
  } else {
    enum argsTemp = n.iota.map!(
      i => "&args[%d]".format(i)
    ).join(", ");
    mixin(
      "readf(fmt, " ~ argsTemp ~ ");"
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
