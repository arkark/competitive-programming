import std.functional;

// // RMQ (Range Minimum Query)
// alias RMQ(T) = SegTree!(T, "a<b ? a:b", T.max);

// Segment Tree
//    - with 1-based array
struct SegTree(T, alias fun, T initValue, bool structly = true)
if (is(typeof(binaryFun!fun(T.init, T.init)) : T)) {

  import std.algorithm : map;
  import std.array : array;

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
