struct DynamicSegTree(T, alias fun, T initValue, bool structly = true)
if (is(typeof(binaryFun!fun(T.init, T.init)) : T)) {

private:
  alias _fun = binaryFun!fun;
  size_t _size;
  Node _root;

public:

  // size: データ数
  this(size_t size) {
    _size = 1;
    while (_size < size) {
      _size <<= 1;
    }
    _root = new Node();
  }

  // i番目の要素をxに変更
  // O(logN)
  void update(size_t i, T x) {
    Node node = getLeafNode(i);
    node.pair = Pair(i, x);
    while (node !is _root) {
      Node parent = node.parent;
      Pair pl = parent.left is null ? Pair() : parent.left.pair;
      Pair pr = parent.right is null ? Pair() : parent.right.pair;
      parent.pair = select(pl, pr);
      node = parent;
    }
  }

  // 区間[a, b)でのクエリ (valueの取得)
  // O(logN)
  T query(size_t a, size_t b) {
    return queryPair(a, b, _root, 0, _size).value;
  }

  // 区間[a, b)でのクエリ (indexの取得)
  // O(logN)
  size_t queryIndex(size_t a, size_t b)
  out (result) {
    // fun == (a, b) => a+b のようなときはindexを聞くとassertion
    if (structly)
      assert(result != size_t.max);
  }
  body {
    return queryPair(a, b, _root, 0, _size).index;
  }

  // 区間[a, b)でのクエリ ((index, value)の取得)
  // O(logN)
  Pair queryPair(size_t a, size_t b)
  out (result) {
    // fun == (a, b) => a+b のようなときはindexを聞くとassertion
    if (structly)
      assert(result.index != size_t.max);
  }
  body {
    return queryPair(a, b, _root, 0, _size);
  }

  // O(logN)
  T get(size_t i) {
    return getLeafNode(i).pair.value;
  }

private:
  struct Pair {
    size_t index = size_t.max;
    T value = initValue;
  }

  class Node {
    Node parent;
    Node left, right;
    Pair pair = Pair();
    this() {
    }

    this(Node parent) {
      this.parent = parent;
    }
  }

  Node getLeafNode(size_t i) {
    Node node = _root;
    size_t l = 0;
    size_t r = _size;
    while (r - l > 1) {
      size_t c = (l + r) >> 1;
      if (i < c) {
        if (node.left is null) {
          node.left = new Node(node);
        }
        node = node.left;
        r = c;
      } else {
        if (node.right is null) {
          node.right = new Node(node);
        }
        node = node.right;
        l = c;
      }
    }
    return node;
  }

  Pair select(Pair pl, Pair pr) {
    T v = _fun(pl.value, pr.value);
    if (pl.value == v) {
      return pl;
    } else if (pr.value == v) {
      return pr;
    } else {
      return Pair(size_t.max, v);
    }
  }

  Pair queryPair(size_t a, size_t b, Node node, size_t l, size_t r) {
    if (r <= a || b <= l) {
      return Pair();
    }
    if (a <= l && r <= b) {
      return node.pair;
    }

    Pair pl = node.left is null ? Pair() : queryPair(a, b, node.left, l, (l + r) >> 1);
    Pair pr = node.right is null ? Pair() : queryPair(a, b, node.right, (l + r) >> 1, r);
    return select(pl, pr);
  }
}
