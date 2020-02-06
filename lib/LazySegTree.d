
// // update(l, r, x) := as[l..r] += x
// // query(l, r) := as[l..r].sum
// struct P {
//   long num, x;
// }
// alias RSQ = LazySegTree!(
//   P, long,
//   (a, b) => P(a.num + b.num, a.x + b.x),
//   "a+b",
//   (a, b) => P(a.num, a.x + b*a.num),
//   P(0, 0),
//   0
// );

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
