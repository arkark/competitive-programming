enum long MOD = 10L^^9+7;
alias ModNum = ModNumber!(long, MOD);

struct ModNumber(T, T mod) if (__traits(isIntegral, T)) {
  private enum FACT_MAX = 2000010;

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
  static ModNumber comb(T n, T r) {
    import std.functional : memoize;
    if (r<0 || r>n) return ModNumber(0);
    if (r*2 > n) return comb(n, n-r);

    if (n<=FACT_MAX) {
      return fact(n) * invFact(r) * invFact(n-r); // 逆元テーブルを使用する
      // return fact(n) / fact(r) / fact(n-r); // 逆元テーブルを使用しない
    }

    // n!/r!
    static ModNumber reverseFact(T n, T r) {
      T t = n - r;
      assert(0<=t && t<=FACT_MAX);
      static ModNumber[][T] memo;
      if (n !in memo) {
        memo[n] = new ModNumber[FACT_MAX];
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

    return reverseFact(n, n-r) / fact(r);
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
