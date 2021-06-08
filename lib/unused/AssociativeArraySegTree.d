// Dynamic Segment Tree
//    - with 1-based associative array

struct DynamicSegTree(T, alias fun, T initValue, bool structly = true)
if (is(typeof(binaryFun!fun(T.init, T.init)) : T)) {

private:
  alias _fun = binaryFun!fun;
  Pair[size_t] _data;
  size_t _size;
  size_t _l, _r;

public:
  // size ... データ数
  // initValue ... 初期値(例えばRMQだとINF)
  this(size_t size) {
    init(size);
  }

  // 配列で指定
  this(T[] ary) {
    init(ary.length);
    update(ary);
  }

  // O(N)
  void init(size_t size) {
    _size = 1;
    while (_size < size) {
      _size *= 2;
    }
    _l = 0;
    _r = size;
  }

  // i番目の要素をxに変更
  // O(logN)
  void update(size_t i, T x) {
    size_t index = i;
    setPair(i += _size, Pair(index, x));
    while (i > 0) {
      i >>= 1;
      Pair nl = getPair(i * 2 + 0);
      Pair nr = getPair(i * 2 + 1);
      setPair(i, select(nl, nr));
    }
  }

  // 配列で指定
  // O(N)
  void update(T[] ary) {
    foreach (i, e; ary) {
      setPair(i + _size, Pair(i, e));
    }
    foreach_reverse (i; 1 .. _size) {
      Pair nl = getPair(i * 2 + 0);
      Pair nr = getPair(i * 2 + 1);
      setPair(i, select(nl, nr));
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
  size_t queryIndex(size_t a, size_t b)
  out (result) {
    // fun == (a, b) => a+b のようなときはindexを聞くとassertion
    if (structly)
      assert(result != size_t.max);
  }
  do {
    Pair pair = accumulate(a, b);
    // Pair pair = queryRec(a, b, 0, 0, _size);
    return pair.index;
  }

  // 区間[a, b)でのクエリ ((index, value)の取得)
  // O(logN)
  Pair queryPair(size_t a, size_t b)
  out (result) {
    // fun == (a, b) => a+b のようなときはindexを聞くとassertion
    if (structly)
      assert(result.index != size_t.max);
  }
  do {
    Pair pair = accumulate(a, b);
    // Pair pair = queryRec(a, b, 0, 0, _size);
    return pair;
  }

  // O(1)
  T get(size_t i) {
    return getPair(_size + i).value;
  }

  // O(N)
  T[] array() {
    return iota(_l, _r).map!(
        i => i + _size
    )
      .map!(
          i => getPair(i)
      )
      .map!"a.value"
      .array;
  }

  struct Pair {
    size_t index;
    T value;
  }

private:
  Pair accumulate(size_t l, size_t r) {
    if (r <= _l || _r <= l)
      return Pair(size_t.max, initValue);
    Pair accl = Pair(size_t.max, initValue);
    Pair accr = Pair(size_t.max, initValue);
    for (l += _size, r += _size; l < r; l >>= 1, r >>= 1) {
      if (l & 1)
        accl = select(accl, getPair(l++));
      if (r & 1)
        accr = select(getPair(r - 1), accr);
    }
    return select(accl, accr);
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

  Pair getPair(size_t i) {
    Pair* p = i in _data;
    if (p) {
      return *p;
    } else {
      return Pair(size_t.max, initValue);
    }
  }

  void setPair(size_t i, Pair pair) {
    _data[i] = pair;
  }
}
