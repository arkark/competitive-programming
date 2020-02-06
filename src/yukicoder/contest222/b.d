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
  long N, Q;
  scanln(N, Q);
  long[] as = readln.split.to!(long[]);

  struct P{
    long l, r, s;
  }

  auto seg = LazySegTree!(
    P, long,
    (a, b) => P(a.l, b.r, a.s + b.s + (a.r != b.l ? 1 : 0)),
    "a+b",
    (a, b) => P(a.l + b, a.r + b, a.s),
    P(-1, -1, 0),
    0
  )(as.map!(a => P(a, a, 0)).array);

  foreach(i; 0..Q) {
    long[] bs = readln.split.to!(long[]);
    bs[1]--;
    bs[2]--;
    if (bs[0] == 1) {
      seg.update(bs[1], bs[2]+1, bs[3]);
    } else {
      seg.query(bs[1], bs[2]+1).pipe!"a.s-1".writeln;
    }
  }
}

// Lazy Segment Tree
//    - with 1-based array
struct LazySegTree(
  M,           // モノイドの型
  X,           // 作用素モノイドの型
  alias funMM, // (M, M) → M : Mの2項演算
  alias funXX, // (X, X) → X : Xの2項演算
  alias funMX, // (M, X) → M : Xの元をMの元に作用させる関数
  M eM,        // Mの単位元
  X eX,        // Xの単位元
  bool structly = true
) if (
  is(typeof(binaryFun!funMM(M.init, M.init)) : M) &&
  is(typeof(binaryFun!funXX(X.init, X.init)) : X) &&
  is(typeof(binaryFun!funMX(M.init, X.init)) : M) &&
  binaryFun!funMM(M.init, M.init) == M.init &&
  binaryFun!funXX(X.init, X.init) == X.init &&
  binaryFun!funMX(M.init, X.init) == M.init
) {

private:
  alias _funMM = binaryFun!funMM;
  alias _funXX = binaryFun!funXX;
  alias _funMX = binaryFun!funMX;
  Pair[] _data;
  X[] _lazy;
  size_t _height;
  size_t _size;
  size_t _l, _r;

public:

  // size: データ数
  this(size_t size) {
    init(size);
  }

  // 配列で指定
  this(M[] ms) {
    init(ms.length);
    build(ms);
  }

  // O(N)
  void init(size_t size){
    _height = 0;
    _size = 1;
    while(_size < size) {
      _size <<= 1;
      _height++;
    }
    _data.length = _size<<1;
    _lazy.length = _size<<1;
    _data[] = Pair(size_t.max, eM);
    _lazy[] = eX;
    _l = 0;
    _r = size;
  }

  // 区間 [a, b) を x ∈ X で作用
  // O(logN)
  void update(size_t a, size_t b, X x) {
    assert(a <= b);
    a += _size;
    b += _size;
    evaluate(a);
    evaluate(b - 1);
    for (size_t l = a, r = b; l < r; l >>= 1, r >>= 1) {
      if (l&1) {
        _lazy[l] = _funXX(_lazy[l], x);
        l++;
      }
      if (r&1) {
        r--;
        _lazy[r] = _funXX(_lazy[r], x);
      }
    }
    recalc(a);
    recalc(b - 1);
  }

  // 区間[a, b)でのクエリ (valueの取得)
  // O(logN)
  M query(size_t a, size_t b) {
    Pair pair = accumulate(a, b);
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
    return pair;
  }

  // i番目の要素を取得
  // O(logN)
  M get(size_t i) {
    i += _size;
    evaluate(i);
    return reflect(i).value;
  }

  // i番目の要素をmに更新
  // O(logN)
  void set(size_t i, M m) {
    i += _size;
    evaluate(i);
    _data[i].value = m;
    _lazy[i] = eX;
    recalc(i);
  }

private:

  struct Pair {
    size_t index;
    M value;
  }

  Pair select(Pair nl, Pair nr) {
    M v = _funMM(nl.value, nr.value);
    if (nl.value == v) {
      return nl;
    } else if (nr.value == v) {
      return nr;
    } else {
      return Pair(size_t.max, v);
    }
  }

  Pair accumulate(size_t a, size_t b) {
    assert(a <= b);
    if (b<=_l || _r<=a) return Pair(size_t.max, eM);
    a += _size;
    b += _size;
    evaluate(a);
    evaluate(b - 1);
    Pair accL = Pair(size_t.max, eM);
    Pair accR = Pair(size_t.max, eM);
    for (size_t l = a, r = b; l < r; l >>= 1, r >>= 1) {
      if (l&1) accL = select(accL, reflect(l++));
      if (r&1) accR = select(reflect(--r), accR);
    }
    return select(accL, accR);
  }

  Pair reflect(size_t i) {
    if (_lazy[i] == eX) {
      return _data[i];
    } else {
      return Pair(
        _data[i].index,
        _funMX(_data[i].value, _lazy[i])
      );
    }
  }

  void thrust(size_t i) {
    if (_lazy[i] == eX) return;
    _lazy[i<<1|0] = _funXX(_lazy[i<<1|0], _lazy[i]);
    _lazy[i<<1|1] = _funXX(_lazy[i<<1|1], _lazy[i]);
    _data[i] = reflect(i);
    _lazy[i] = eX;
  }

  void evaluate(size_t i) {
    foreach_reverse(k; 0.._height) {
      thrust(i>>(k+1));
    }
  }

  void recalc(size_t i) {
    while(i > 0) {
      i >>= 1;
      _data[i] = select(reflect(i<<1|0), reflect(i<<1|1));
    }
  }

  // O(N)
  void build(M[] ms) {
    foreach(i, e; ms) {
      _data[i+_size] = Pair(i, e);
    }
    foreach_reverse(i; 1.._size) {
      Pair nl = _data[i<<1|0];
      Pair nr = _data[i<<1|1];
      _data[i] = select(nl, nr);
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
