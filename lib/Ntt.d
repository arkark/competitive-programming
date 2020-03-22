// Number Theoretic Transform (任意mod)
//   ref: https://satanic0258.github.io/snippets/math/NTT.html

/*
  long t = ...;
  long[] as = ...;
  long[] bs = ...;

  long[] cs = Ntt.mul(as, bs, t); // -> 多項式の積 as * bs mod t
*/
struct Ntt {
  import std.algorithm : swap;
  private {
    enum long[] MOD_LIST = [1224736769, 469762049, 167772161];
    enum long[] PRIMITIVE_ROOT_LIST = [3, 3, 3];
    enum long NTT_CONVOLUTION_TIME = 3;
  }

  static long[] mul(long[] as, long[] bs, long mod) {
    as = as.dup;
    bs = bs.dup;
    foreach(ref a; as) a = ((a%mod) + mod)%mod;
    foreach(ref b; bs) b = ((b%mod) + mod)%mod;

    size_t m = as.length + bs.length - 1;
    size_t sz = 1;
    while(sz < m) sz <<= 1;
    as.length = sz;
    bs.length = sz;

    long[][] css = new long[][NTT_CONVOLUTION_TIME];
    if (NTT_CONVOLUTION_TIME >= 1) {
      css[0] = NttPart!(MOD_LIST[0], PRIMITIVE_ROOT_LIST[0]).mul(as, bs);
    }
    if (NTT_CONVOLUTION_TIME >= 2) {
      css[1] = NttPart!(MOD_LIST[1], PRIMITIVE_ROOT_LIST[1]).mul(as, bs);
    }
    if (NTT_CONVOLUTION_TIME >= 3) {
      css[2] = NttPart!(MOD_LIST[2], PRIMITIVE_ROOT_LIST[2]).mul(as, bs);
    }

    foreach(ref cs; css) {
      cs.length = m;
    }
    garner(css, mod);
    return css[0];
  }

  private static long powMod(long base, long power, long mod) {
    long res = 1;
    for(; power > 0; power >>= 1) {
      if (power & 1) {
        res = res * base % mod;
      }
      base = base * base % mod;
    }
    return res;
  }

  private static long invMod(long base, long mod) {
    return powMod(base, mod - 2, mod);
  }

  private static void garner(long[][] css, long mod) {
    size_t sz = css[0].length;
    static if (NTT_CONVOLUTION_TIME == 1) {
      foreach(ref c; css[0]) {
        c %= mod;
      }
    } else if (NTT_CONVOLUTION_TIME == 2) {
      enum long r01 = invMod(MOD_LIST[0], MOD_LIST[1]);
      foreach(i; 0..sz) {
        css[1][i] = (css[1][i] - css[0][i]) * r01 % MOD_LIST[1];
        if (css[1][i] < 0) css[1][i] += MOD_LIST[1];
        css[0][i] = (css[0][i] + css[1][i] * MOD_LIST[0]) % mod;
      }
    } else if (NTT_CONVOLUTION_TIME == 3) {
      enum long r01 = invMod(MOD_LIST[0], MOD_LIST[1]);
      enum long r02 = invMod(MOD_LIST[0], MOD_LIST[2]);
      enum long r12 = invMod(MOD_LIST[1], MOD_LIST[2]);
      long m01 = MOD_LIST[0] * MOD_LIST[1] % mod;
      foreach(i; 0..sz) {
        css[1][i] = (css[1][i] - css[0][i]) * r01 % MOD_LIST[1];
        if (css[1][i] < 0) css[1][i] += MOD_LIST[1];
        css[2][i] = ((css[2][i] - css[0][i]) * r02 % MOD_LIST[2] - css[1][i]) * r12 % MOD_LIST[2];
        if (css[2][i] < 0) css[2][i] += MOD_LIST[2];
        css[0][i] = (css[0][i] + css[1][i] * MOD_LIST[0] + css[2][i] * m01) % mod;
      }
    } else {
      assert(false);
    }
  }

  private struct NttPart(long mod, long primitiveRoot) {
    static long[] ntt(long[] as, bool inv = false) {
      as = as.dup;
      size_t sz = as.length;

      size_t mask = sz - 1;
      size_t p = 0;
      long[] tmp = new long[sz];
      for(size_t i = sz >> 1; i > 0; i >>= 1) {
        long[] cur = (p&1) ? tmp : as;
        long[] nex = (p&1) ? as : tmp;
        long e = powMod(primitiveRoot, (mod - 1)/sz*i, mod);
        if (inv) {
          e = invMod(e, mod);
        }
        long w = 1;
        for(size_t j = 0; j < sz; j += i) {
          foreach(k; 0..i) {
            nex[j + k] = (cur[(j<<1&mask) + k] + w * cur[(((j<<1) + i)&mask) + k]) % mod;
          }
          w = w * e % mod;
        }
        p++;
      }
      if (p&1) {
        swap(as, tmp);
      }
      if (inv) {
        long invSz = invMod(sz, mod);
        foreach(i; 0..sz) {
          as[i] = as[i] * invSz % mod;
        }
      }
      return as;
    }

    static long[] mul(long[] as, long[] bs) {
      as = ntt(as);
      bs = ntt(bs);
      size_t sz = as.length;
      foreach(i; 0..sz) {
        as[i] = as[i] * bs[i] % mod;
      }
      as = ntt(as, true);
      return as;
    }
  }
}
