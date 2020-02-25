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
  long N, Q;
  scanln(N, Q);

  long[] xs = N.iota.array;
  if (N==26) {
    xs.mergeSort!((a, b) => memoize!query(a, b))(0, N);
  } else {
    xs.sort!((a, b) => memoize!query(a, b));
  }
  answer(xs);
}

bool query(long c1, long c2) {
  if (c1 > c2) {
    return !memoize!query(c2, c1);
  }
  writeln("? ", cast(char)('A' + c1), " ", cast(char)('A' + c2));
  stdout.flush;
  string ans = readln.chomp;
  return ans == "<";
}

void answer(long[] ans) {
  writeln(
    "! ",
    ans.map!(x => (cast(char)('A'+x)).to!string).join("")
  );
}

void mergeSort(alias less)(long[] xs, long l, long r) {
  if (r - l <= 1) return;
  long m = (l + r)/2;
  mergeSort!less(xs, l, m);
  mergeSort!less(xs, m, r);
  merge!less(xs, l, m, r);
}

void merge(alias less)(long[] xs, long l, long m, long r) {
  alias _less = binaryFun!less;
  long n1 = m - l;
  long n2 = r - m;
  long[] ls = new long[n1];
  long[] rs = new long[n2];
  foreach(i; 0..n1) {
    ls[i] = xs[l+i];
  }
  foreach(j; 0..n2) {
    rs[j] = xs[m+j];
  }

  long i = 0;
  long j = 0;
  long k = l;
  while(i < n1 && j < n2) {
    if (_less(ls[i], rs[j])) {
      xs[k++] = ls[i++];
    } else {
      xs[k++] = rs[j++];
    }
  }
  while(i < n1) {
    xs[k++] = ls[i++];
  }
  while(j < n2) {
    xs[k++] = rs[j++];
  }
  assert(k == r);
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
