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

void main() {
  long N;
  scanln(N);

  long[][] xss = N.rep!(
    () => readln.chomp.map!(a => a=='('?1L:-1L).array
  );

  struct P {
    long l;
    long s;
  }
  P[] ps = new P[N];
  foreach(i, xs; xss) {
    long l = 0;
    long s = 0;
    foreach(x; xs) {
      s += x;
      l.ch!min(s);
    }
    ps[i] = P(l, s);
  }

  auto tree1 = redBlackTree!(
    (a, b) => a.l != b.l ? a.l > b.l : a.s > b.s,
    true,
    P,
  )();
  auto tree2 = redBlackTree!(
    (a, b) => a.s != b.s ? a.s > b.s : a.l < b.l,
    true,
    P,
  )();

  auto tree3 = redBlackTree!(
    (a, b) => a.l != b.l ? a.l > b.l : a.s > b.s,
    true,
    P,
  )();
  auto tree4 = redBlackTree!(
    (a, b) => a.s != b.s ? a.s > b.s : a.l < b.l,
    true,
    P,
  )();

  foreach(p; ps) {
    if (p.s >= 0) {
      tree1.insert(p);
    } else {
      tree3.insert(P(p.l - p.s, -p.s));
    }
  }

  long s1 = 0;
  while(!tree1.empty || !tree2.empty) {
    while(!tree1.empty) {
      P p = tree1.front;
      if (s1 + p.l >= 0) {
        tree2.insert(p);
        tree1.removeFront;
      } else {
        break;
      }
    }
    while(!tree2.empty) {
      P p = tree2.front;
      if (s1 + p.l < 0) {
        tree2.removeFront;
        tree1.insert(p);
      } else {
        break;
      }
    }
    if (tree2.empty) break;
    P p = tree2.front;
    tree2.removeFront;
    s1 += p.s;
  }

  long s2 = 0;
  while(!tree3.empty || !tree4.empty) {
    while(!tree3.empty) {
      P p = tree3.front;
      if (s2 + p.l >= 0) {
        tree4.insert(p);
        tree3.removeFront;
      } else {
        break;
      }
    }
    while(!tree4.empty) {
      P p = tree4.front;
      if (s2 + p.l < 0) {
        tree4.removeFront;
        tree3.insert(p);
      } else {
        break;
      }
    }
    if (tree4.empty) break;
    P p = tree4.front;
    tree4.removeFront;
    s2 += p.s;
  }

  assert(tree2.empty && tree4.empty);
  writeln(s1 == s2 && tree1.empty && tree3.empty ? "Yes" : "No");
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

template scanln(Args...) {
  enum sep = " ";

  enum n = (){
    long n = 0;
    foreach(Arg; Args) {
      static if (is(Arg == class) || is(Arg == struct) || is(Arg == union)) {
        n += Fields!Arg.length;
      } else {
        n++;
      }
    }
    return n;
  }();

  enum fmt = n.rep!(()=>"%s").join(sep);

  enum argsString = (){
    string[] xs = [];
    foreach(i, Arg; Args) {
      static if (is(Arg == class) || is(Arg == struct) || is(Arg == union)) {
        foreach(T; FieldNameTuple!Arg) {
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
    x = (x & 0x5555555555555555L) + (x>> 1 & 0x5555555555555555L);
    x = (x & 0x3333333333333333L) + (x>> 2 & 0x3333333333333333L);
    x = (x & 0x0f0f0f0f0f0f0f0fL) + (x>> 4 & 0x0f0f0f0f0f0f0f0fL);
    x = (x & 0x00ff00ff00ff00ffL) + (x>> 8 & 0x00ff00ff00ff00ffL);
    x = (x & 0x0000ffff0000ffffL) + (x>>16 & 0x0000ffff0000ffffL);
    x = (x & 0x00000000ffffffffL) + (x>>32 & 0x00000000ffffffffL);
    return x;
  }
}
