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

enum long INF = long.max/5;
enum long MOD = 10L^^9+7;

void main() {
  long N;
  scanln(N);

  long[] as = readln.split.to!(long[]);
  long[] bs = readln.split.to!(long[]);

  long[] xs = new long[N];
  long[] ys = new long[N];
  foreach(i; 0..N) {
    if (i%2==0) {
      xs[i] = as[i];
      ys[i] = bs[i];
    } else {
      ys[i] = as[i];
      xs[i] = bs[i];
    }
  }

  long ans = INF;
  long[] ps = new long[N];
  long[] qs = new long[N];
  long[] rs = new long[N];
  long[] us = new long[N];
  foreach(bits; 0L..1L<<N) {
    long s = 0;
    foreach(i; 0..N) {
      if (bits>>i&1) {
        ps[s] = xs[i];
        s++;
      } else {
        qs[i-s] = ys[i];
      }
    }
    if (s != N.ceil(2)) {
      continue;
    }
    {
      bool ok = true;
      long[] ps2 = ps[0..s].dup.sort!"a<b".array;
      long[] qs2 = qs[0..N-s].dup.sort!"a<b".array;
      long t1 = -INF;
      long t2 = -INF;
      foreach(i; 0..ps2.length) {
        t2 = ps2[i];
        ok &= t1 <= t2;
        t1 = t2;
        if (i < qs2.length) {
          t2 = qs2[i];
          ok &= t1 <= t2;
          t1 = t2;
        }
      }
      if (!ok) continue;

      foreach(i; 0..s) {
        {
          long t = INF;
          long k = -1;
          foreach(j, p; ps[0..s]) {
            if (p < t) {
              t = p;
              k = j;
            }
          }
          ps2[k] = 2*i;
          ps[k] = INF;
        }
        if (i < N-s) {
          long t = INF;
          long k = -1;
          foreach(j, q; qs[0..N-s]) {
            if (q < t) {
              t = q;
              k = j;
            }
          }
          qs2[k] = 2*i+1;
          qs[k] = INF;
        }
      }

      s = 0;
      foreach(i; 0..N) {
        if (bits>>i&1) {
          us[i] = ps2[s];
          s++;
        } else {
          us[i] = qs2[i-s];
        }
      }
    }
    ans.ch!min(
      us.inversion
    );
  }
  if (ans == INF) {
    writeln(-1);
  } else {
    ans.writeln;
  }
}

long inversion(long[] xs) {
  long N = xs.length;

  long[long] aa;
  xs.dup.sort!"a<b".uniq.enumerate.each!(a => aa[a.value] = a.index);

  long[] ys = xs.map!(x => aa[x]).array;

  auto seg = SegTree!(long, (a, b) => a+b, 0L)(N+1);
  long res = 0;
  foreach(i; 0..N) {
    res += seg.query(ys[i], N);
    seg.update(ys[i], seg.get(ys[i]) + 1);
  }
  return res;
}

// // RMQ (Range Minimum Query)
// alias RMQ(T) = SegTree!(T, "a<b ? a:b", T.max);

// Segment Tree
//    - with 1-based array
struct SegTree(T, alias fun, T initValue, bool structly = true)
  if (is(typeof(binaryFun!fun(T.init, T.init)) : T)) {

private:
  alias _fun = binaryFun!fun;
  Pair[] _data;
  size_t _size;
  size_t _l, _r;

public:

  // size: データ数
  this(size_t size) {
    init(size);
  }

  // 配列で指定
  this(T[] xs) {
    init(xs.length);
    update(xs);
  }

  // O(N)
  void init(size_t size){
    _size = 1;
    while(_size < size) {
      _size *= 2;
    }
    _data.length = _size*2;
    _data[] = Pair(size_t.max, initValue);
    _l = 0;
    _r = size;
  }

  // i番目の要素をxに変更
  // O(logN)
  void update(size_t i, T x) {
    size_t index = i;
    _data[i += _size] = Pair(index, x);
    while(i > 0) {
      i >>= 1;
      Pair nl = _data[i*2+0];
      Pair nr = _data[i*2+1];
      _data[i] = select(nl, nr);
    }
  }

  // 配列で指定
  // O(N)
  void update(T[] ary) {
    foreach(i, e; ary) {
      _data[i+_size] = Pair(i, e);
    }
    foreach_reverse(i; 1.._size) {
      Pair nl = _data[i*2+0];
      Pair nr = _data[i*2+1];
      _data[i] = select(nl, nr);
    }
  }

  // 区間[a, b)でのクエリ (valueの取得)
  // O(logN)
  T query(size_t a, size_t b) {
    Pair pair = accumulate(a, b);
    // Pair pair = queryRec(a, b, 0, 0, _size);
    return pair.value;
  }

  // 区間[a, b)でのクエリ (indexの取得)
  // O(logN)
  size_t queryIndex(size_t a, size_t b) out(result) {
    // fun == (a, b) => a+b のようなときはindexを聞くとassertion
    if (structly) assert(result != size_t.max);
  } body {
    Pair pair = accumulate(a, b);
    return pair.index;
  }

  // 区間[a, b)でのクエリ ((index, value)の取得)
  // O(logN)
  Pair queryPair(size_t a, size_t b) out(result) {
    // fun == (a, b) => a+b のようなときはindexを聞くとassertion
    if (structly) assert(result.index != size_t.max);
  } body {
    Pair pair = accumulate(a, b);
    // Pair pair = queryRec(a, b, 0, 0, _size);
    return pair;
  }

  // O(1)
  T get(size_t i) {
    return _data[_size + i].value;
  }

  // O(N)
  T[] array() {
    return _data[_l+_size.._r+_size].map!"a.value".array;
  }

private:

  struct Pair {
    size_t index;
    T value;
  }

  Pair select(Pair nl, Pair nr) {
    T v = _fun(nl.value, nr.value);
    if (nl.value == v) {
      return nl;
    } else if (nr.value == v) {
      return nr;
    } else {
      return Pair(size_t.max, v);
    }
  }

  Pair accumulate(size_t l, size_t r) {
    if (r<=_l || _r<=l) return Pair(size_t.max, initValue);
    Pair accl = Pair(size_t.max, initValue);
    Pair accr = Pair(size_t.max, initValue);
    for (l += _size, r += _size; l < r; l >>= 1, r >>= 1) {
      if (l&1) accl = select(accl, _data[l++]);
      if (r&1) accr = select(_data[r-1], accr);
    }
    return select(accl, accr);
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
