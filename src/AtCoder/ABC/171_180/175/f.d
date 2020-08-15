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
  string prefix;
  string suffix;
  Edge[] edges;

  long value = INF;
  mixin Constructor;
}
struct Edge {
  Vertex end;
  long value;
}

void main() {
  long N;
  scanln(N);

  struct P {
    string str;
    string rev;
    long c;
  }
  P[] ps = new P[N];
  foreach(i; 0..N) {
    string s;
    long c;
    scanln(s, c);
    ps[i] = P(s, s.retro.to!string, c);
  }

  Vertex[string] prefixA;
  Vertex[string] suffixA;

  Vertex s = new Vertex("-", "-");

  {
    Vertex v = new Vertex("", "");
    prefixA[""] = v;
    suffixA[""] = v;
  }

  bool isPalindrome(string str) {
    foreach(i; 0..str.length/2) {
      if (str[i] != str[$-i-1]) return false;
    }
    return true;
  }

  foreach(p; ps) {
    foreach(i; 0..p.str.length) {
      string prefix = p.str[i..$];
      string suffix = p.str[0..$-i];
      prefixA[prefix] = new Vertex(prefix, "");
      suffixA[suffix] = new Vertex("", suffix);
    }
  }
  foreach(p; ps) {
    s.edges ~= Edge(prefixA[p.str], p.c);
    s.edges ~= Edge(suffixA[p.str], p.c);
  }

  foreach(p; ps) {
    foreach(prefix, v; prefixA) {
      if (isPalindrome(prefix)) continue;
      string sub = commonPrefix(prefix, p.rev);
      Vertex u;
      if (sub == p.rev) {
        u = prefixA[prefix[sub.length..$]];
      } else if (sub == prefix) {
        u = suffixA[p.str[0..p.str.length-sub.length]];
      } else {
        continue;
      }
      v.edges ~= Edge(u, p.c);
    }
    foreach(suffix, v; suffixA) {
      if (isPalindrome(suffix)) continue;
      string sub = commonPrefix(suffix.retro.to!string, p.str);
      Vertex u;
      if (sub == p.str) {
        u = suffixA[suffix[0..suffix.length-sub.length]];
      } else if (sub == suffix.retro.to!string) {
        u = prefixA[p.str[sub.length..$]];
      } else {
        continue;
      }
      v.edges ~= Edge(u, p.c);
    }
  }

  s.value = 0;
  auto tree = redBlackTree!(
    "a.value != b.value ? a.value < b.value : a.prefix != b.prefix ? a.prefix < b.prefix : a.suffix < b.suffix",
    true,
    Vertex,
  )(s);

  while(!tree.empty) {
    Vertex v = tree.front;
    tree.removeFront;
    foreach(e; v.edges) {
      Vertex u = e.end;
      long value = v.value + e.value;
      if (value < u.value) {
        tree.removeKey(u);
        u.value = value;
        tree.insert(u);
      }
    }
  }

  long ans = INF;
  foreach(prefix, v; prefixA) {
    if (isPalindrome(prefix)) ans.ch!min(v.value);
  }
  foreach(suffix, v; suffixA) {
    if (isPalindrome(suffix)) ans.ch!min(v.value);
  }
  writeln(ans==INF ? -1 : ans);
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
