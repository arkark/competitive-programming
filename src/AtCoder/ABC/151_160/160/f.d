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
import std.regex;
import core.bitop : popcnt;
alias Generator = std.concurrency.Generator;

enum long INF = long.max/5;

class Vertex {
  long index;
  Vertex[] vs;
  ModNum[] cs;
  long[] nums;
  long maxJ = -1;
  mixin Constructor;
}

void main() {
  long N;
  scanln(N);

  struct M {
    ModNum value;
    long notEatenNum;
    long num;
  }

  auto rerooting = Rerooting!(
    M, bool,
    (a, b) => M(
      a.value*b.value*ModNum.invFact(a.notEatenNum)*ModNum.invFact(b.notEatenNum),
      0,
      a.num + b.num,
    ),
    (a, _) => M(
      a.value*ModNum.fact(a.num),
      a.num + 1,
      a.num + 1,
    ),
    M(ModNum(1), 0, 0),
    false
  )(N);

  foreach(i; 0..N-1) {
    long a, b;
    scanln(a, b);
    a--; b--;
    rerooting.addEdge(a, b);
  }

  foreach(m; rerooting.solve) {
    m.value.writeln;
  }
}

template Rerooting(
  M,              // DPの要素の型
  X,              // 各頂点がもつ値の型
  alias fun,      // DPの要素間の2項演算
  alias afterFun, // 頂点の値からDPの要素への作用
  M identity,     // DPの要素の単位元
  bool ctfeCheckActive = true,
) {
  import std.algorithm : map;
  import std.array : array;
  import std.functional : binaryFun;

  static if (ctfeCheckActive) {
    static assert(is(typeof(binaryFun!fun(identity, identity)) : M));
    static assert(is(typeof(binaryFun!afterFun(identity, X.init)) : M));
    static assert(binaryFun!fun(identity, identity) == identity);
  }

  struct Rerooting {

  private:
    alias _fun = binaryFun!fun;
    alias _afterFun = binaryFun!afterFun;

    Vertex[] _vertices;

  public:
    // O(n)
    this(size_t n) {
      _vertices.length = n;
      foreach(i; 0..n) {
        _vertices[i] = new Vertex(X.init);
      }
    }

    // O(n)
    this(X[] values) {
      _vertices = values.map!(
        value => new Vertex(value)
      ).array;
    }

    size_t size() {
      return _vertices.length;
    }

    void addEdge(size_t x, size_t y) {
      _vertices[x].adj ~= _vertices[y];
      _vertices[y].adj ~= _vertices[x];
    }

    M[] solve(size_t rootIndex = 0) in {
      assert(rootIndex < size);
    } body {
      Vertex[] vs = getOrderedVertices(rootIndex);

      foreach_reverse(v; vs) {
        M acc = identity;
        foreach(u; v.adj) {
          if (u is v.parent) continue;
          acc = _fun(acc, u.dpValue);
        }
        acc = _afterFun(acc, v.value);
        v.dpValue = acc;
      }

      M[] accL = new M[size];
      M[] accR = new M[size];
      foreach(v; vs) {
        size_t len = v.adj.length;
        assert(len+1 <= size);
        accL[0] = identity;
        accR[len] = identity;
        foreach(j, u; v.adj) {
          accL[j+1] = _fun(
            accL[j],
            u is v.parent ? v.parentDpValue : u.dpValue
          );
        }
        foreach_reverse(j, u; v.adj) {
          accR[j] = _fun(
            u is v.parent ? v.parentDpValue : u.dpValue,
            accR[j+1]
          );
        }
        assert(accL[len] == accR[0]);
        v.dpValue = _afterFun(accL[len], v.value);

        foreach(j, u; v.adj) {
          if (u is v.parent) continue;
          u.parentDpValue = _afterFun(
            _fun(accL[j], accR[j+1]),
            v.value
          );
        }
      }

      return _vertices.map!"a.dpValue".array;
    }

  private:
    class Vertex {
      X value;
      M dpValue;
      Vertex[] adj;
      Vertex parent;
      M parentDpValue;
      this(X value) {
        this.value = value;
      }
    }

    Vertex[] getOrderedVertices(size_t rootIndex) {
      Vertex[] vs = new Vertex[size];
      size_t index = 0;

      auto stack = DList!Vertex(_vertices[rootIndex]);
      while(!stack.empty) {
        Vertex v = stack.back;
        stack.removeBack;
        vs[index++] = v;
        foreach(u; v.adj) {
          if (u is v.parent) continue;
          u.parent = v;
          stack.insertBack(u);
        }
      }
      assert(index == size);

      return vs;
    }
  }
}

enum long MOD = 10L^^9+7;
alias ModNum = ModNumber!(long, MOD);

struct ModNumber(T, T mod) if (__traits(isIntegral, T)) {
  private enum FACT_SIZE = 10000010; // size of memo for factorization
  private enum LUCAS_SIZE = 1010;    // size of memo for Lucas's theorem

  T value;
  this(T value) {
    this.value = value;
    this.value %= mod;
    this.value += mod;
    this.value %= mod;
  }

  ModNumber opAssign(T value) {
    return this = ModNumber(value);
  }

  ModNumber opBinary(string op)(ModNumber that) if (op=="+" || op=="-" || op=="*") {
    return ModNumber(mixin("this.value "~op~" that.value"));
  }
  ModNumber opBinary(string op)(T that) if (op=="+" || op=="-" || op=="*") {
    return ModNumber(mixin("this.value "~op~" that"));
  }
  ModNumber opBinaryRight(string op)(T that) if (op=="+" || op=="-" || op=="*") {
    return ModNumber(mixin("that "~op~" this.value"));
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
    if (x.value == 0) {
      throw new Exception("divide by 0");
    }
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
    if (n >= mod) {
      return ModNumber(0);
    }

    assert(0 <= n && n <= FACT_SIZE);
    static ModNumber[] memo;
    if (memo.length == 0) {
      memo = new ModNumber[FACT_SIZE + 1];
      memo[0] = ModNumber(1);
      assert(memo[0] != ModNumber.init);
    }
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
    assert(0 <= n && n <= FACT_SIZE);
    assert(n < mod);

    static ModNumber inverse(T n) {
      assert(1 <= n && n <= FACT_SIZE);
      static ModNumber[] memo;
      if (memo.length == 0) {
        memo = new ModNumber[FACT_SIZE + 1];
      }
      if (memo[n] != ModNumber.init) {
        return memo[n];
      } else {
        return memo[n] = n==1 ? ModNumber(1) : ModNumber(-mod/n)*inverse(mod%n);
      }
    }

    static ModNumber[] memo;
    if (memo.length == 0) {
      memo = new ModNumber[FACT_SIZE + 1];
      memo[0] = 1;
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
  template comb() {
    static ModNumber comb(T n, T r) {
      if (r<0 || r>n) return ModNumber(0);
      if (r*2 > n) return comb(n, n-r);

      if (r < mod && n-r < mod) {

        if (n <= FACT_SIZE) {
          return fact(n) * invFact(r) * invFact(n-r); // 逆元テーブルを使用する
          // return fact(n) / fact(r) / fact(n-r); // 逆元テーブルを使用しない
        } else if (r <= FACT_SIZE) {
          return reverseFact(n, n-r) / fact(r);
        } else {
          assert(false);
        }

      } else {

        // Lucas's theorem
        static if (mod == 2) {
          return ModNumber((n&r) == r);
        } else static if (mod <= LUCAS_SIZE) {
          ModNumber res = 1;
          while(n > 0 || r > 0) {
            T n2 = n % mod;
            T r2 = r % mod;
            res *= tableComb(n2, r2);
            n /= mod;
            r /= mod;
          }
          return res;
        } else {
          assert(false);
        }

      }
    }

    // n!/r!
    private static ModNumber reverseFact(T n, T r) {
      T t = n - r;
      assert(0<=t && t<=FACT_SIZE);
      static ModNumber[][T] memo;
      if (n !in memo) {
        memo[n] = new ModNumber[FACT_SIZE];
        memo[n][0] = 1;
        assert(memo[n][0] != ModNumber.init);
      }
      auto xs = memo[n];
      foreach_reverse(i; 0..t+1) {
        if (xs[i] != ModNumber.init) {
          foreach(j; i+1..t+1) {
            xs[j] = xs[j-1] * (n - j + 1);
          }
          return xs[t];
        }
      }
      assert(false);
    }

    static if (mod <= LUCAS_SIZE) {
      private static tableComb(T n, T r) in {
        assert(0 <= n && n <= LUCAS_SIZE);
        assert(0 <= r && r <= LUCAS_SIZE);
      } body {
        static ModNumber[][] memo;
        if (memo.length == 0) {
          memo = new ModNumber[][](LUCAS_SIZE + 1, LUCAS_SIZE + 1);
          memo[0][0] = 1;
          foreach(i; 1..LUCAS_SIZE+1) {
            memo[i][0] = 1;
            foreach(j; 1..LUCAS_SIZE+1) {
              memo[i][j] = memo[i-1][j-1] + memo[i-1][j];
            }
          }
        }
        return memo[n][r];
      }
    }
  }

  // {}_n H_r: 重複組合せ (Homogeneous Combination)
  static ModNumber hComb(T n, T r) {
    return comb(n+r-1, r);
  }

  string toString() const {
    import std.conv : to;
    return this.value.to!string;
  }

  invariant {
    assert(this.value>=0);
    assert(this.value<mod);
  }
}

@safe pure unittest {
  enum p = 10L^^9 + 7;
  alias ModNum = ModNumber!(long, p);

  ModNum x;
  assert(x.value == 0);
  x = 10;
  assert(x.value == 10);
  x = -10;
  assert(x.value == -10 + p);
  x = 10L^^9 + 7 + 10;
  assert(x.value == 10);
}

@safe pure unittest {
  enum p = 10L^^9 + 7;
  alias ModNum = ModNumber!(long, p);

  ModNum x = 10;
  ModNum y = p - 5;
  assert(x + y == ModNum(5));
  assert(x - y == ModNum(15));
  assert(x * y == ModNum(10*p - 50));

  ModNum z = x / y;
  assert(z * y == x);

  try {
    scope(success) assert(false);
    ModNum w = 0;
    x / w;
  } catch(Exception e) {
  }
}

@safe unittest {
  enum p1 = 10L^^9 + 7;
  enum p2 = 3;
  alias ModNum1 = ModNumber!(long, p1);
  alias ModNum2 = ModNumber!(long, p2);

  assert(ModNum1.fact(0).value == 1);
  assert(ModNum1.fact(1).value == 1);
  assert(ModNum1.fact(5).value == 120);
  assert(ModNum1.fact(100).value == 437918130);

  assert(ModNum2.fact(0).value == 1);
  assert(ModNum2.fact(1).value == 1);
  assert(ModNum2.fact(2).value == 2);
  assert(ModNum2.fact(3).value == 0);
  assert(ModNum2.fact(100).value == 0);
}

@safe unittest {
  // TODO: comb, hComb
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
