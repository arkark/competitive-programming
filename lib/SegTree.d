// // RMQ (Range Minimum Query)
// alias RMQ(T) = SegTree!(T, (a, b) => a<b ? a:b, T.max);

// SegTree (Segment Tree)
struct SegTree(T, alias fun, T initValue, bool structly = true)
  if (is(typeof(fun(T.init, T.init)) : T)) {

private:
  Node[] _data;
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
  void init(size_t size){
    _size = 1;
    while(_size < size) {
      _size *= 2;
    }
    _data.length = _size*2-1;
    _data[] = Node(size_t.max, initValue);
    _l = 0;
    _r = size;
  }

  // i番目の要素をxに変更
  // O(logN)
  void update(size_t i, T x) {
    size_t index = i;
    i += _size-1;
    _data[i] = Node(index, x);
    while(i > 0) {
      i = (i-1)/2;
      Node nl = _data[i*2+1];
      Node nr = _data[i*2+2];
      _data[i] = select(nl, nr);
    }
  }

  // 配列で指定
  // O(N)
  void update(T[] ary) {
    foreach(i, e; ary) {
      _data[i+_size-1] = Node(i, e);
    }
    foreach(i; (_size-1).iota.retro) {
      Node nl = _data[i*2+1];
      Node nr = _data[i*2+2];
      _data[i] = select(nl, nr);
    }
  }

  // 区間[a, b)でのクエリ (valueの取得)
  // O(logN)
  T query(size_t a, size_t b) {
    return queryRec(a, b, 0, 0, _size).value;
  }

  // 区間[a, b)でのクエリ (indexの取得)
  // O(logN)
  size_t queryIndex(size_t a, size_t b) out(result) {
    // fun == (a, b) => a+b のようなときはindexを聞くとassertion
    if (structly) assert(result != size_t.max);
  } body {
    return queryRec(a, b, 0, 0, _size).index;
  }

  // 区間[a, b)でのクエリ ((index, value)の取得)
  // O(logN)
  Tuple!(size_t, "index", T, "value") queryPair(size_t a, size_t b) out(result) {
    // fun == (a, b) => a+b のようなときはindexを聞くとassertion
    if (structly) assert(result.index != size_t.max);
  } body {
    Node node = queryRec(a, b, 0, 0, _size);
    return tuple!("index", "value")(node.index, node.value);
  }

  private Node queryRec(size_t a, size_t b, size_t k, size_t l, size_t r) {
    if (b<=l || r<=a) return Node(size_t.max, initValue);
    if (a<=l && r<=b) return _data[k];
    Node nl = queryRec(a, b, k*2+1, l, (l+r)/2);
    Node nr = queryRec(a, b, k*2+2, (l+r)/2, r);
    return select(nl, nr);
  }

  private Node select(Node nl, Node nr) {
    T v = fun(nl.value, nr.value);
    if (nl.value == v) {
      return nl;
    } else if (nr.value == v) {
      return nr;
    } else {
      return Node(size_t.max, v);
    }
  }

  // O(1)
  T get(size_t i) {
    return _data[_size-1 + i].value;
  }

  // O(N)
  T[] array() {
    return _data[_l+_size-1.._r+_size-1].map!"a.value".array;
  }

private:
  struct Node {
    size_t index;
    T value;
  }
}
