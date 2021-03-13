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

enum long INF = long.max / 5;

void main() {
  long A, B;
  scanln(A, B);

  long K = B - A + 1;
  long[] ps = getPrimes(K);
  long T = ps.length;

  long[][] dp = new long[][](2, 1L << T);
  dp[0][0] = 1;
  foreach (i; 0 .. K) {
    dp[(i + 1) % 2][] = dp[i % 2];

    long x = A + i;
    long cur = 0;
    foreach (j; 0 .. T) {
      if (x % ps[j] == 0) {
        cur |= 1L << j;
      }
    }
    foreach (bits; 0 .. 1L << T) {
      if ((bits & cur) == 0) {
        long next = bits | cur;
        dp[(i + 1) % 2][next] += dp[i % 2][bits];
      }
    }
  }
  dp[K % 2].sum.writeln;
}

// sieve of Eratosthenes

bool[] getIsPrimes(long limit) @safe pure {
  bool[] isPrimes = new bool[limit + 1];
  if (isPrimes.length >= 2)
    isPrimes[2 .. $] = true;
  for (long i = 2; i * i <= isPrimes.length; i++) {
    if (isPrimes[i]) {
      for (long j = i * i; j < isPrimes.length; j += i) {
        isPrimes[j] = false;
      }
    }
  }
  return isPrimes;
}

long[] getPrimes(long limit) @safe pure {
  bool[] isPrimes = new bool[limit + 1];
  if (isPrimes.length >= 2)
    isPrimes[2 .. $] = true;
  for (long i = 2; i * i <= isPrimes.length; i++) {
    if (isPrimes[i]) {
      for (long j = i * i; j < isPrimes.length; j += i) {
        isPrimes[j] = false;
      }
    }
  }
  long[] primes = [];
  foreach (long i, flg; isPrimes) {
    if (flg)
      primes ~= i;
  }
  return primes;
}

@safe pure unittest {
  long n = 12;
  assert(n.getIsPrimes == [
      false, // 0
      false, // 1
      true, // 2
      true, // 3
      false, // 4
      true, // 5
      false, // 6
      true, // 7
      false, // 8
      false, // 9
      false, // 10
      true, // 11
      false, // 12
      ]);
  assert(n.getPrimes == [
      2, 3, 5, 7, 11
      ]);
}

// ----------------------------------------------

void times(alias fun)(long n) {
  // n.iota.each!(i => fun());
  foreach (i; 0 .. n)
    fun();
}

auto rep(alias fun, T = typeof(fun()))(long n) {
  // return n.iota.map!(i => fun()).array;
  T[] res = new T[n];
  foreach (ref e; res)
    e = fun();
  return res;
}

T ceil(T)(T x, T y) if (isIntegral!T || is(T == BigInt)) {
  // `(x+y-1)/y` will only work for positive numbers ...
  T t = x / y;
  if (y > 0 && t * y < x)
    t++;
  if (y < 0 && t * y > x)
    t++;
  return t;
}

T floor(T)(T x, T y) if (isIntegral!T || is(T == BigInt)) {
  T t = x / y;
  if (y > 0 && t * y > x)
    t--;
  if (y < 0 && t * y < x)
    t--;
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
    foreach (i, v; args) {
      mixin("this." ~ FieldNameTuple!(typeof(this))[i]) = v;
    }
  }
}

template scanln(Args...) {
  enum sep = " ";

  enum n = () {
    long n = 0;
    foreach (Arg; Args) {
      static if (is(Arg == class) || is(Arg == struct) || is(Arg == union)) {
        n += Fields!Arg.length;
      } else {
        n++;
      }
    }
    return n;
  }();

  enum fmt = n.rep!(() => "%s").join(sep);

  enum argsString = () {
    string[] xs = [];
    foreach (i, Arg; Args) {
      static if (is(Arg == class) || is(Arg == struct) || is(Arg == union)) {
        foreach (T; FieldNameTuple!Arg) {
          xs ~= "&args[%d].%s".format(i, T);
        }
      } else {
        xs ~= "&args[%d]".format(i);
      }
    }
    return xs.join(", ");
  }();

  void scanln(auto ref Args args) {
    string line = readln.chomp;
    static if (__VERSION__ >= 2074) {
      mixin(
          "line.formattedRead!fmt(%s);".format(argsString)
      );
    } else {
      mixin(
          "line.formattedRead(fmt, %s);".format(argsString)
      );
    }
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
    x = (x & 0x5555555555555555L) + (x >> 1 & 0x5555555555555555L);
    x = (x & 0x3333333333333333L) + (x >> 2 & 0x3333333333333333L);
    x = (x & 0x0f0f0f0f0f0f0f0fL) + (x >> 4 & 0x0f0f0f0f0f0f0f0fL);
    x = (x & 0x00ff00ff00ff00ffL) + (x >> 8 & 0x00ff00ff00ff00ffL);
    x = (x & 0x0000ffff0000ffffL) + (x >> 16 & 0x0000ffff0000ffffL);
    x = (x & 0x00000000ffffffffL) + (x >> 32 & 0x00000000ffffffffL);
    return x;
  }
}
