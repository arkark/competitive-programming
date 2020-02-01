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

void main() {
  string s = readln.chomp;
  string t = readln.chomp;

  long K = 2000000;

  string x = "";
  while(x.length < K) {
    x ~= t;
  }
  string y = "";
  while(y.length <= x.length) {
    y ~= s;
  }

  long l = 0;
  long r = K.floor(t.length) + 1;
  while(r - l > 1) {
    long c = (l + r)/2;
    string z = x[0..t.length*c];
    if (searchPattern(y, z).empty) {
      r = c;
    } else {
      l = c;
    }
  }

  if (l == K.floor(t.length)) {
    writeln(-1);
  } else {
    writeln(l);
  }
}

/*
  KMP法
  @return:
    out[0] == -1
    out[i] == max { ys.length | ys is a prefix of xs[0..i] and a suffix of xs[0..i] }
  計算量
    - 全体: O(n)
    - 各ステップ: 最悪 O(log n)
 */
long[] solveKmp(T)(T[] xs) {
  long n = xs.length;
  long[] kmp = new long[n+1];
  long[] mp = new long[n+1];
  long j = -1;
  kmp[0] = mp[0] = j;
  foreach(i; 0..n) {
    while(j >= 0 && xs[i] != xs[j]) {
      j = kmp[j];
    }
    kmp[i+1] = mp[i+1] = ++j;
    if (i+1 < n && xs[i+1] == xs[j]) {
      kmp[i+1] = kmp[j];
    }
  }
  return mp;
}

/*
  textからpatternに一致する開始インデックスを列挙する
  - O(n + m)
 */
long[] searchPattern(T)(T[] text, T[] pattern) {
  long n = text.length;
  long m = pattern.length;
  assert(m <= n);
  long[] indices = [];
  long[] kmp = solveKmp!T(pattern);
  long i = 0; // index for `text`
  long j = 0; // index for `pattern`
  while(i < n) {
    while(j >= 0 && text[i] != pattern[j]) {
      j = kmp[j];
    }
    j++;
    i++;
    if (j == m) {
      assert(i >= m);
      indices ~= i-m;
      j = kmp[j-1];
      i--;
    }
  }
  return indices;
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
