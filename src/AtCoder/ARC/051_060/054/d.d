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

alias Seg = DynamicSegTree!(ModNum, "a+b", ModNum(0));

void main() {
  long N;
  scanln(N);
  long T = 100000;
  long[] as = readln.split.to!(long[]);

  long size = 0;
  Node[] ns = new Node[5000000];
  foreach(a; as) {
    if (a > 0) {
      Node v = new Node(
        0, 0, 1, 1, 1, [a: ModNum(1)], Seg(T+1)
      );
      v.seg.update(a, ModNum(1));
      ns[size++] = v;
    } else if (a < 0) {
      assert(size >= 1);
      ModNum k = -a;
      Node n = ns[size-1];
      ModNum x = n.x;
      ModNum y = n.y;
      n.x = k*x + k*(k-1)/2*y;
      n.y = k*k*y;
      n.scale *= k;
    } else {
      assert(size >= 2);
      Node n2 = ns[--size];
      Node n1 = ns[--size];
      Node n3;
      ModNum newX = n1.x + n2.x;
      ModNum newY = n1.y + n2.y;
      if (n1.cnt < n2.cnt) {
        foreach(k, t; n1.ds) {
          ModNum smaller = n2.seg.query(0, k);
          ModNum cnt = n2.sum;
          if (k in n2.ds) cnt -= n2.ds[k];
          newX += smaller * n2.scale * t*n1.scale;
          newY += cnt*n2.scale * t*n1.scale;
        }
      } else {
        foreach(k, t; n2.ds) {
          ModNum larger = n1.seg.query(k+1, T+1);
          ModNum cnt = n1.sum;
          if (k in n1.ds) cnt -= n1.ds[k];
          newX += larger * n1.scale * t*n2.scale;
          newY += cnt*n1.scale * t*n2.scale;
        }
        swap(n1, n2);
      }
      n3 = n2;
      ModNum r = n1.scale/n2.scale;
      foreach(k, t; n1.ds) {
        if (k !in n3.ds) {
          n3.ds[k] = ModNum(0);
          n3.cnt++;
        }
        ModNum u = t*r;
        n3.sum += u;
        n3.ds[k] += u;
        n3.seg.update(k, n3.ds[k]);
      }
      n3.x = newX;
      n3.y = newY;
      ns[size++] = n3;
    }
  }
  assert(size == 1);
  ns.front.x.writeln;
}

class Node {
  ModNum x, y;
  ModNum scale;
  long cnt;
  ModNum sum;
  ModNum[long] ds;
  Seg seg;
  mixin Constructor;
}

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
    while(_size < size) {
      _size <<= 1;
    }
    _root = new Node();
  }

  // i番目の要素をxに変更
  // O(logN)
  void update(size_t i, T x) {
    Node node = getLeafNode(i);
    node.pair = Pair(i, x);
    while(node !is _root) {
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
  size_t queryIndex(size_t a, size_t b) out(result) {
    // fun == (a, b) => a+b のようなときはindexを聞くとassertion
    if (structly) assert(result != size_t.max);
  } body {
    return queryPair(a, b, _root, 0, _size).index;
  }

  // 区間[a, b)でのクエリ ((index, value)の取得)
  // O(logN)
  Pair queryPair(size_t a, size_t b) out(result) {
    // fun == (a, b) => a+b のようなときはindexを聞くとassertion
    if (structly) assert(result.index != size_t.max);
  } body {
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
    while(r - l > 1) {
      size_t c = (l + r)>>1;
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

    Pair pl = node.left is null ? Pair() : queryPair(a, b, node.left, l, (l + r)>>1);
    Pair pr = node.right is null ? Pair() : queryPair(a, b, node.right, (l + r)>>1, r);
    return select(pl, pr);
  }
}

alias ModNum = ModNumber!(long, MOD);

struct ModNumber(T, T mod) if (__traits(isIntegral, T)) {
  private enum FACT_MAX = 1000010;

  T value;
  this(T value) {
    this.value = value;
    this.value %= mod;
    this.value += mod;
    this.value %= mod;
  }

  ModNumber opAssign(T value) {
    this.value = value;
    return this;
  }

  ModNumber opBinary(string op)(ModNumber that) if (op=="+" || op=="-" || op=="*") {
    return ModNumber(mixin("(this.value "~op~" that.value + mod) % mod"));
  }
  ModNumber opBinary(string op)(T that) if (op=="+" || op=="-" || op=="*") {
    return ModNumber(mixin("(this.value "~op~" that + mod) % mod"));
  }
  ModNumber opBinaryRight(string op)(T that) if (op=="+" || op=="-" || op=="*") {
    return ModNumber(mixin("(that "~op~" this.value + mod) % mod"));
  }

  ModNumber opBinary(string op)(ModNumber that) if (op == "/") {
    return this*getReciprocal(that);
  }
  ModNumber opBinary(string op)(T that) if (op == "/") {
    return this*getReciprocal(ModNumber(that));
  }
  ModNumber opBinaryRight(string op)(T that) if (op == "/") {
    return ModNumber(that)*getReciprocal(this);
  }

  ModNumber opBinary(string op)(ModNumber that) if (op == "^^") {
    return ModNumber(modPow(this.value, that.value));
  }
  ModNumber opBinary(string op)(T that) if (op == "^^") {
    return ModNumber(modPow(this.value, that));
  }
  ModNumber opBinaryRight(string op)(T that) if (op == "^^") {
    return ModNumber(modPow(that, this.value));
  }

  void opOpAssign(string op)(ModNumber that) if (op=="+" || op=="-" || op=="*" || op=="/") {
    this = mixin("this" ~op~ "that");
  }
  void opOpAssign(string op)(T that) if (op=="+" || op=="-" || op=="*" || op=="/") {
    this = mixin("this" ~op~ "that");
  }

  ModNumber getReciprocal(ModNumber x) in {
    debug assert(isPrime(mod));
  } body {
    return ModNumber(modPow(x.value, mod-2));
  }
  T modPow(T base, T power)  {
    T result = 1;
    for (; power > 0; power >>= 1) {
      if (power & 1) {
        result = (result * base) % mod;
      }
      base = base*base % mod;
    }
    return result;
  }

  static bool isPrime(T n) {
    if (n<2) {
      return false;
    } else if (n==2) {
      return true;
    } else if (n%2==0) {
      return false;
    } else {
      for(T i=3; i*i<=n; i+=2) {
        if (n%i==0) return false;
      }
      return true;
    }
  }

  // n! : 階乗
  static ModNumber fact(T n) {
    assert(0<=n && n<=FACT_MAX);
    static ModNumber[] memo;
    if (memo.length == 0) {
      memo = new ModNumber[FACT_MAX+1];
      memo[0] = ModNumber(1);
      assert(memo[0] != ModNumber.init);
    }
    auto acc = ModNumber(1);
    foreach_reverse(i; 0..n+1) {
      if (memo[i] != ModNumber.init) {
        foreach(j; i+1..n+1) {
          memo[j] = memo[j-1] * j;
        }
        return memo[n];
      }
    }
    assert(false);
  }

  // 1/(n!) : 階乗の逆元 (逆元テーブルを用いる)
  static ModNumber invFact(T n) {
    assert(0<=n && n<=FACT_MAX);
    static ModNumber inverse(T n) {
      assert(1<=n && n<=FACT_MAX);
      static ModNumber[] memo;
      if (memo.length == 0) {
        memo = new ModNumber[FACT_MAX+1];
      }
      if (memo[n] != ModNumber.init) {
        return memo[n];
      } else {
        return memo[n] = n==1 ? ModNumber(1) : ModNumber(-mod/n)*inverse(mod%n);
      }
    }
    static ModNumber[] memo;
    if (memo.length == 0) {
      memo = new ModNumber[FACT_MAX+1];
      memo[0] = ModNumber(1);
      assert(memo[0] != ModNumber.init);
    }
    foreach_reverse(i; 0..n+1) {
      if (memo[i] != ModNumber.init) {
        foreach(j; i+1..n+1) {
          memo[j] = memo[j-1] * inverse(j);
        }
        return memo[n];
      }
    }
    assert(false);
  }

  // {}_n C_r: 組合せ
  static ModNumber comb(T n, T r) {
    import std.functional : memoize;
    if (r<0 || r>n) return ModNumber(0);
    if (r*2 > n) return comb(n, n-r);

    if (n<=FACT_MAX) {
      return fact(n) * invFact(r) * invFact(n-r); // 逆元テーブルを使用する
      // return fact(n) / fact(r) / fact(n-r); // 逆元テーブルを使用しない
    }

    ModNumber mul(T l, T r) {
      return l>r ? ModNumber(1) : l * memoize!mul(l+1, r);
    }
    return memoize!mul(n-r+1, n) / memoize!mul(1, r);
  }

  // {}_n H_r: 重複組合せ (Homogeneous Combination)
  static ModNumber hComb(T n, T r) {
    return comb(n+r-1, r);
  }

  string toString() {
    import std.conv;
    return this.value.to!string;
  }

  invariant {
    assert(this.value>=0);
    assert(this.value<mod);
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
