import std.typecons : Tuple, tuple;
import std.numeric : gcd;

// @return: gcd(a, b)
// @side x, y:
//   s.t. ax + by = gcd(a, b)
long extgcd(long a, long b, ref long x, ref long y) {
  long g = a;
  if (b != 0) {
    g = extgcd(b, a % b, y, x);
    y -= (a / b) * x;
  } else {
    x = 1;
    y = 0;
  }
  return g;
}

// @return: a^-1 mod m
// @assert: gcd(a, m) = 1
long inverseMod(long a, long m)
in {
  assert(gcd(a, m) == 1);
}
body {
  long x, y;
  extgcd(a, m, x, y);
  return (x % m + m) % m;
}

// Solve 連立線形合同式
// @return x, m:
//   s.t. ∀i, as[i] * x = bs[i] mod ms[i]
//        m = lcm(ms[0..$])
//        0 ≦ x < m
// このとき、この制約を満たすxはこれしか存在しない
Tuple!(long, "x", long, "m") chineseRemainderTheorem(long[] as, long[] bs, long[] ms)
in {
  assert(as.length == bs.length);
  assert(as.length == ms.length);
}
body {
  auto result = tuple!("x", "m")(0L, 1L);
  foreach (i; 0 .. as.length) {
    long s = as[i] * result.m;
    long t = bs[i] - as[i] * result.x;
    long d = gcd(ms[i], s);
    if (t % d != 0) {
      return tuple!("x", "m")(-1L, -1L); // not found
    }
    long u = t / d * inverseMod(s / d, ms[i] / d) % (ms[i] / d);
    result.x += result.m * u;
    result.m *= ms[i] / d;
    result.x = (result.x % result.m + result.m) % result.m;
  }
  return result;
}
