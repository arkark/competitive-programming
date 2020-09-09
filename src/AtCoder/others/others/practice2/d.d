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
  long N, M;
  scanln(N, M);
  bool[][] xss = N.rep!(() => readln.chomp.map!"a=='#'".array);

  auto graph = MfGraph!long(N * M + 2);
  long s = N * M;
  long t = N * M + 1;
  long p(long i, long j) {
    return i * M + j;
  }

  long[] dy = [-1, 0, 1, 0];
  long[] dx = [0, -1, 0, 1];

  long[][][] esss = new long[][][](N, M, 4);

  foreach (i; 0 .. N) {
    foreach (j; 0 .. M) {
      if ((i + j) % 2 == 0) {
        graph.addEdge(s, p(i, j), 1);
        foreach (k; 0 .. 4) {
          long i2 = i + dy[k];
          long j2 = j + dx[k];
          if (i2 < 0 || i2 >= N)
            continue;
          if (j2 < 0 || j2 >= M)
            continue;
          if (xss[i][j] || xss[i2][j2])
            continue;
          esss[i][j][k] = graph.addEdge(p(i, j), p(i2, j2), 1);
        }
      } else {
        graph.addEdge(p(i, j), t, 1);
      }
    }
  }

  graph.flow(s, t).writeln;

  char[][] yss = new char[][](N, M);
  foreach (i; 0 .. N) {
    foreach (j; 0 .. M) {
      yss[i][j] = xss[i][j] ? '#' : '.';
    }
  }

  foreach (i; 0 .. N) {
    foreach (j; 0 .. M) {
      if ((i + j) % 2 != 0)
        continue;
      foreach (k; 0 .. 4) {
        long i2 = i + dy[k];
        long j2 = j + dx[k];
        if (i2 < 0 || i2 >= N)
          continue;
        if (j2 < 0 || j2 >= M)
          continue;
        if (xss[i][j] || xss[i2][j2])
          continue;
        auto e = graph.getEdge(esss[i][j][k]);
        if (e.flow == 1) {
          yss[i][j] = "^<v>"[k];
          yss[i2][j2] = "v>^<"[k];
        }
      }
    }
  }

  yss.each!writeln;
}

static struct InternalArray {

  // Array
  //   - Dynamic array in D is slow.
  //   - ac-library does not contain this.
  struct Array(T) {
    import std.algorithm : min, max;
    import std.conv : to;
    import std.format : format;

  private:
    T[] data = [];
    size_t size = 0;

    // [beginIndex, endIndex)
    size_t beginIndex = 0;
    size_t endIndex = 0;

  public:

    this(T[] data) {
      this(data, data.length, 0, data.length, false);
    }

    bool empty() @property {
      return beginIndex == endIndex;
    }

    size_t length() @property {
      return endIndex - beginIndex;
    }

    void clear() {
      beginIndex = endIndex = 0;
      data = [];
      size = 0;
    }

    ref T front() @property
    in {
      assert(!empty, "Attempting to get the front of an empty Array");
    }
    body {
      return this[0];
    }

    ref T front(T value) @property
    in {
      assert(!empty, "Attempting to assign to the front of an empty Array");
    }
    body {
      return this[0] = value;
    }

    ref T back() @property
    in {
      assert(!empty, "Attempting to get the back of an empty Array");
    }
    body {
      return this[$ - 1];
    }

    ref T back(T value) @property
    in {
      assert(!empty, "Attempting to assign to the back of an empty Array");
    }
    body {
      return this[$ - 1] = value;
    }

    void insertBack(T value) {
      if (size >= data.length) {
        resize();
      }
      data[size++] = value;
      endIndex++;
    }

    void removeFront()
    in {
      assert(!empty, "Attempting to remove the front of an empty Array");
    }
    body {
      beginIndex++;
    }

    alias popFront = removeFront;

    void removeBack()
    in {
      assert(!empty, "Attempting to remove the back of an empty Array");
    }
    body {
      size--;
      endIndex--;
    }

    alias popBack = removeBack;

    typeof(this) save() @property {
      return typeof(this)(data, size, beginIndex, endIndex, true);
    }

    alias dup = save;

    // xs ~= value
    typeof(this) opOpAssign(string op)(T value) if (op == "~") {
      this.insertBack(value);
      return this;
    }

    // xs[index]
    ref T opIndex(size_t index)
    in {
      assert(0 <= index && index < length, "Access violation");
    }
    body {
      size_t _index = beginIndex + index;
      return data[_index];
    }

    // xs[indices[0] .. indices[1]]
    typeof(this) opIndex(size_t[2] indices)
    in {
      assert(0 <= indices[0] && indices[1] <= length, "Access violation");
    }
    body {
      size_t newBeginIndex = beginIndex + indices[0];
      size_t newEndIndex = beginIndex + indices[1];
      size_t size = newEndIndex;
      return typeof(this)(data, size, newBeginIndex, newEndIndex, false);
    }

    // xs[]
    typeof(this) opIndex() {
      return this;
    }

    // xs[index] = value
    ref T opIndexAssign(T value, size_t index)
    in {
      assert(0 <= index && index < length, "Access violation");
    }
    body {
      size_t _index = index - beginIndex;
      return data[_index] = value;
    }

    // xs[indices[0] .. indices[1]] = value
    typeof(this) opIndexAssign(T value, size_t[2] indices)
    in {
      assert(0 <= indices[0] && indices[1] <= length, "Access violation");
    }
    body {
      size_t _beginIndex = beginIndex + indices[0];
      size_t _endIndex = beginIndex + indices[1];
      data[_beginIndex .. _endIndex] = value;
      return this;
    }

    // xs[] = value
    typeof(this) opIndexAssign(T value) {
      data[0 .. size] = value;
      return this;
    }

    // xs[indices[0] .. indices[1]] op= value
    typeof(this) opIndexOpAssign(string op)(T value, size_t[2] indices)
    in {
      assert(0 <= indices[0] && indices[1] <= length, "Access violation");
    }
    body {
      size_t _beginIndex = beginIndex + indices[0];
      size_t _endIndex = beginIndex + indices[1];
      mixin(q{
      data[_beginIndex.._endIndex] %s= value;
    }.format(op));
      return this;
    }

    // xs[] op= value
    typeof(this) opIndexOpAssign(string op)(T value) {
      mixin(q{
      data[0..size] %s= value;
    }.format(op));
      return this;
    }

    // $
    size_t opDollar(size_t dim : 0)() {
      return length;
    }

    // i..j
    size_t[2] opSlice(size_t dim : 0)(size_t i, size_t j)
    in {
      assert(0 <= i && j <= length, "Access violation");
    }
    body {
      return [i, j];
    }

    bool opEquals(S : T)(Array!S that) {
      if (this.length != that.length)
        return false;
      foreach (i; 0 .. this.length) {
        if (this[i] != that[i])
          return false;
      }
      return true;
    }

    bool opEquals(S : T)(S[] that) {
      if (this.length != that.length)
        return false;
      foreach (i; 0 .. this.length) {
        if (this[i] != that[i])
          return false;
      }
      return true;
    }

    string toString() const {
      auto xs = data[beginIndex .. endIndex];
      return "Array(%s)".format(xs);
    }

    void reserve(size_t size) {
      data.length = max(data.length, size);
    }

  private:
    this(T[] data, size_t size, size_t beginIndex, ptrdiff_t endIndex, bool shouldDuplicate) {
      this.size = size;
      this.data = shouldDuplicate ? data.dup : data[0 .. min(endIndex, $)];
      this.beginIndex = beginIndex;
      this.endIndex = endIndex;
    }

    void resize() {
      data.length = max(size * 2, 1);
    }

    invariant {
      assert(size <= data.length);
      assert(beginIndex <= endIndex);
      assert(endIndex == size);
    }
  }

  @safe pure unittest {
    // Array should be Range
    import std.range;

    assert(isInputRange!(Array!long));
    // assert(isOutputRange!(Array!long, int));
    // assert(isOutputRange!(Array!long, long));
    assert(isForwardRange!(Array!long));
    assert(isBidirectionalRange!(Array!long));
    assert(isRandomAccessRange!(Array!long));
  }

  @safe pure unittest {
    // test basic operations

    Array!long xs = [1, 2, 3]; // == Array!long([1, 2, 3])
    assert(xs.length == 3);
    assert(xs.front == 1 && xs.back == 3);
    assert(xs[0] == 1 && xs[1] == 2 && xs[2] == 3);
    assert(xs == [1, 2, 3]);

    size_t i = 0;
    foreach (x; xs) {
      assert(x == ++i);
    }

    xs.front = 4;
    xs[1] = 5;
    xs.back = 6;
    assert(xs == [4, 5, 6]);

    xs.removeBack;
    xs.removeBack;
    assert(xs == [4]);
    xs.insertBack(5);
    xs ~= 6;
    assert(xs == [4, 5, 6]);
    xs.removeFront;
    assert(xs == [5, 6]);

    xs.clear;
    assert(xs.empty);
    xs.insertBack(1);
    assert(!xs.empty);
    assert(xs == [1]);
    xs[0]++;
    assert(xs == [2]);
  }

  @safe pure unittest {
    // test slicing operations

    Array!long xs = [1, 2, 3];
    assert(xs[] == [1, 2, 3]);
    assert((xs[0 .. 2] = 0) == [0, 0, 3]);
    assert((xs[0 .. 2] += 1) == [1, 1, 3]);
    assert((xs[] -= 2) == [-1, -1, 1]);

    Array!long ys = xs[0 .. 2];
    assert(ys == [-1, -1]);
    ys[0] = 5;
    assert(ys == [5, -1]);
    assert(xs == [5, -1, 1]);
  }

  @safe pure unittest {
    // test using phobos
    import std.algorithm, std.array;

    Array!long xs = [10, 5, 8, 3];
    assert(sort!"a<b"(xs).equal([3, 5, 8, 10]));
    assert(xs == [3, 5, 8, 10]);
    Array!long ys = sort!"a>b"(xs).array;
    assert(ys == [10, 8, 5, 3]);
  }

  @safe pure unittest {
    // test different types of equality

    int[] xs = [1, 2, 3];
    Array!int ys = [1, 2, 3];
    Array!long zs = [1, 2, 3];
    assert(xs == ys);
    assert(xs == zs);
    assert(ys == zs);

    ys.removeBack;
    assert(ys != zs);
    ys.insertBack(3);
    assert(ys == zs);
  }
}

import std.traits : isIntegral;

struct MfGraph(Cap) if (isIntegral!Cap) {
  import std.algorithm : min;
  import std.typecons : Tuple, tuple;

private:
  long _n;
  Tuple!(long, long)[] pos;
  _Edge[][] g;

public:
  this(long n) {
    _n = n;
    g = new _Edge[][n];
  }

  long addEdge(long fromV, long toV, Cap cap)
  in (0 <= fromV && fromV < _n)
  in (0 <= toV && toV < _n)
  in (0 <= cap) {
    long m = pos.length;
    pos ~= tuple(fromV, cast(long) g[fromV].length);
    g[fromV] ~= _Edge(toV, g[toV].length, cap);
    g[toV] ~= _Edge(fromV, g[fromV].length - 1, 0);
    return m;
  }

  struct Edge {
    long fromV, toV;
    Cap cap, flow;
  }

  Edge getEdge(long i) {
    long m = pos.length;
    assert(0 <= i && i < m);
    auto _e = g[pos[i][0]][pos[i][1]];
    auto _re = g[_e.toV][_e.rev];
    return Edge(pos[i][0], _e.toV, _e.cap + _re.cap, _re.cap);
  }

  Edge[] edges() {
    long m = pos.length;
    Edge[] result;
    foreach (i; 0 .. m) {
      result ~= getEdge(i);
    }
    return result;
  }

  void changeEdge(long i, Cap newCap, Cap newFlow) {
    long m = pos.length;
    assert(0 <= i && i < m);
    assert(0 <= newFlow && newFlow <= newCap);
    auto _e = &g[pos[i][0]][pos[i][1]];
    auto _re = &g[_e.toV][_e.rev];
    _e.cap = newCap - newFlow;
    _re.cap = newFlow;
  }

  Cap flow(long s, long t) {
    return flow(s, t, Cap.max);
  }

  Cap flow(long s, long t, Cap flowLimit)
  in (0 <= s && s < _n)
  in (0 <= t && t < _n) {
    long[] level = new long[_n];
    long[] iter = new long[_n];
    InternalArray.Array!long que;

    void bfs() {
      level[] = -1;
      level[s] = 0;
      que.clear();
      que.insertBack(s);
      while (!que.empty) {
        long v = que.front;
        que.removeFront;
        foreach (e; g[v]) {
          if (e.cap == 0 || level[e.toV] >= 0)
            continue;
          level[e.toV] = level[v] + 1;
          if (e.toV == t)
            return;
          que.insertBack(e.toV);
        }
      }
    }

    Cap dfs(long v, Cap up) {
      if (v == s)
        return up;
      Cap res = 0;
      long levelV = level[v];
      for (; iter[v] < g[v].length; iter[v]++) {
        long i = iter[v];
        auto e = g[v][i];
        if (levelV <= level[e.toV] || g[e.toV][e.rev].cap == 0)
          continue;
        Cap d = dfs(e.toV, min(up - res, g[e.toV][e.rev].cap));
        if (d <= 0)
          continue;
        g[v][i].cap += d;
        g[e.toV][e.rev].cap -= d;
        res += d;
        if (res == up)
          break;
      }
      return res;
    }

    Cap flow = 0;
    while (flow < flowLimit) {
      bfs();
      if (level[t] == -1)
        break;
      iter[] = 0;
      while (flow < flowLimit) {
        Cap f = dfs(t, flowLimit - flow);
        if (f == 0)
          break;
        flow += f;
      }
    }
    return flow;
  }

  bool[] minCut(long s) {
    bool[] visited = new bool[_n];
    InternalArray.Array!long que;
    que.insertBack(s);
    while (!que.empty) {
      long p = que.front;
      que.removeFront;
      visited[p] = true;
      foreach (e; g[p]) {
        if (e.cap && !visited[e.toV]) {
          visited[e.toV] = true;
          que.insertBack(e.toV);
        }
      }
    }
    return visited;
  }

private:
  struct _Edge {
    long toV;
    long rev;
    Cap cap;
    this(long toV, long rev, Cap cap) {
      this.toV = toV;
      this.rev = rev;
      this.cap = cap;
    }
  }
}

unittest {
  MfGraph!long g;
  // TODO
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
