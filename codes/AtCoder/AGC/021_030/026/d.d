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

enum long INF = long.max/3;
enum long MOD = 10L^^9+7;

struct P {
  ModNum x, y;
  this(T)(T x, T y) {
    this.x = x;
    this.y = y;
  }
  P opBinary(string op)(P that) {
    return P(mixin("this.x"~op~"that.x"), mixin("this.y"~op~"that.y"));
  }
  void opOpAssign(string op)(P that) {
      this = mixin("this" ~op~ "that");
  }
}

void main() {
  long N;
  scanln(N);
  long[] hs = readln.split.to!(long[]);
  auto seg = SegTree!(long, (a, b) => a<b ? a : b, INF)(hs);

  P f(long l, long r, long bottom) {
    assert(l <= r);
    if (l == r) return P(1, 1);

    long top = seg.query(l, r);
    long diff = top - bottom;
    assert(diff > 0);

    if (diff == 1) {
      P p = P(1, 1);
      long j = l;
      foreach(i; l..r) {
        if (hs[i] == top) {
          P q = f(j, i, bottom);
          p *= q;
          p *= P(2, 1);
          j = i+1;
        }
      }
      P q = f(j, r, bottom);
      p *= q;
      return p;
    } else {
      P q = f(l, r, top-1);
      P p = P(
        q.x-2*q.y + 2*q.y*ModNum(2)^^(diff-1),
        2*q.y*ModNum(2)^^(diff-2)
      );
      return p;
    }
  }

  f(0, N, 0).x.writeln;
}

// RMQ (Range Minimum Query)
// alias RMQ(T) = SegTree!(T, (a, b) => a<b ? a:b, T.max);

// SegTree (Segment Tree)
struct SegTree(T, alias fun, T initValue)
    if (is(typeof(fun(T.init, T.init)) : T)) {

private:
    Node[] _data;
    size_t _size;
    size_t _l, _r;

public:
    // size ... データ数
    // initValue ... 初期値(例えばRMQだとINF)
    this(size_t size) {
        init(size);
    }

    // 配列で指定
    this(T[] ary) {
        init(ary.length);
        update(ary);
    }

    // O(N)
    void init(size_t size){
        _size = 1;
        while(_size < size) {
            _size *= 2;
        }
        _data.length = _size*2-1;
        _data[] = Node(size_t.max, initValue);
        _l = 0;
        _r = size;
    }

    // i番目の要素をxに変更
    // O(logN)
    void update(size_t i, T x) {
        size_t index = i;
        i += _size-1;
        _data[i] = Node(index, x);
        while(i > 0) {
            i = (i-1)/2;
            Node nl = _data[i*2+1];
            Node nr = _data[i*2+2];
            _data[i] = select(nl, nr);
        }
    }

    // 配列で指定
    // O(N)
    void update(T[] ary) {
        foreach(i, e; ary) {
            _data[i+_size-1] = Node(i, e);
        }
        foreach(i; (_size-1).iota.retro) {
            Node nl = _data[i*2+1];
            Node nr = _data[i*2+2];
            _data[i] = select(nl, nr);
        }
    }

    // 区間[a, b)でのクエリ (値の取得)
    // O(logN)
    T query(size_t a, size_t b) {
        return queryRec(a, b, 0, 0, _size).value;
    }

    // 区間[a, b)でのクエリ (indexの取得)
    // O(logN)
    size_t queryIndex(size_t a, size_t b) out(result) {
        // fun == (a, b) => a+b のようなときはindexを聞くとassertion
        assert(result != size_t.max);
    } body {
        return queryRec(a, b, 0, 0, _size).index;
    }

    private Node queryRec(size_t a, size_t b, size_t k, size_t l, size_t r) {
        if (b<=l || r<=a) return Node(size_t.max, initValue);
        if (a<=l && r<=b) return _data[k];
        Node nl = queryRec(a, b, k*2+1, l, (l+r)/2);
        Node nr = queryRec(a, b, k*2+2, (l+r)/2, r);
        return select(nl, nr);
    }

    private Node select(Node nl, Node nr) {
        T v = fun(nl.value, nr.value);
        if (nl.value == v) {
            return nl;
        } else if (nr.value == v) {
            return nr;
        } else {
            return Node(size_t.max, v);
        }
    }

    // O(1)
    T get(size_t i) {
        return _data[_size-1 + i].value;
    }

    // O(N)
    T[] array() {
        return _data[_l+_size-1.._r+_size-1].map!"a.value".array;
    }

private:
    struct Node {
        size_t index;
        T value;
    }
}


alias ModNum = ModNumber!(long, MOD);

struct ModNumber(T, T mod) if (__traits(isIntegral, T)) {
    private enum FACT_MAX = 1000000;

    T value;
    this(T value) {
        this.value = value;
        this.value %= mod;
        this.value += mod;
        this.value %= mod;
    }

    ModNumber opAssign(T value) {
        this.value = value;
        return this;
    }

    ModNumber opBinary(string op)(ModNumber that) if (op=="+" || op=="-" || op=="*") {
        return ModNumber(mixin("(this.value "~op~" that.value + mod) % mod"));
    }
    ModNumber opBinary(string op)(T that) if (op=="+" || op=="-" || op=="*") {
        return ModNumber(mixin("(this.value "~op~" that + mod) % mod"));
    }
    ModNumber opBinaryRight(string op)(T that) if (op=="+" || op=="-" || op=="*") {
        return ModNumber(mixin("(that "~op~" this.value + mod) % mod"));
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
        if (memo.length == 0) memo = new ModNumber[FACT_MAX+1];
        if (memo[n] != ModNumber.init) {
            return memo[n];
        } else {
            return memo[n] = n==0 ? ModNumber(1) : n*fact(n-1);
        }
    }

    // 1/(n!) : 階乗の逆元 (逆元テーブルを用いる)
    static ModNumber invFact(T n) {
        assert(0<=n && n<=FACT_MAX);
        static ModNumber inverse(T n) {
            assert(1<=n && n<=FACT_MAX);
            static ModNumber[] memo;
            if (memo.length == 0) memo = new ModNumber[FACT_MAX+1];
            if (memo[n] != ModNumber.init) {
                return memo[n];
            } else {
                return memo[n] = n==1 ? ModNumber(1) : ModNumber(-mod/n)*inverse(mod%n);
            }
        }
        static ModNumber[] memo;
        if (memo.length == 0) memo = new ModNumber[FACT_MAX+1];
        if (memo[n] != ModNumber.init) {
            return memo[n];
        } else {
            return memo[n] = n==0 ? ModNumber(1) : inverse(n)*invFact(n-1);
        }
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

        ModNum mul(T l, T r) {
            return l>r ? ModNumber(1) : l * memoize!mul(l+1, r);
        }
        return memoize!mul(n-r+1, n) / memoize!mul(1, r);
    }

    // {}_n H_r: 重複組合せ (Homogeneous Combination)
    static ModNumber hComb(T n, T r) {
        return comb(n+r-1, r);
    }

    string toString() {
        import std.conv;
        return this.value.to!string;
    }

    invariant {
        assert(this.value>=0);
        assert(this.value<mod);
    }
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
    if (t * y < x) t++;
    return t;
}

T floor(T)(T x, T y) if (isIntegral!T || is(T == BigInt)) {
    T t = x / y;
    if (t * y > x) t--;
    return t;
}

void ch(alias fun, T, S...)(ref T lhs, S rhs) {
  lhs = fun(lhs, rhs);
}
unittest {
  long x = 1000;
  x.ch!min(2000);
  assert(x == 1000);
  x.ch!min(3, 2, 1);
  assert(x == 1);
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
    import std.meta;
    template getFormat(T) {
        static if (isIntegral!T) {
            enum getFormat = "%d";
        } else static if (isFloatingPoint!T) {
            enum getFormat = "%g";
        } else static if (isSomeString!T || isSomeChar!T) {
            enum getFormat = "%s";
        } else {
            static assert(false);
        }
    }
    enum string str = [staticMap!(getFormat, Args)].join(" ") ~ "\n";
    // readf!str(args);
    mixin("str.readf(" ~ Args.length.iota.map!(i => "&args[%d]".format(i)).join(", ") ~ ");");
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

// cumulativeFold was added in D 2.072.0
static if (__VERSION__ < 2072) {
    template cumulativeFold(fun...)
    if (fun.length >= 1)
    {
        import std.meta : staticMap;
        private alias binfuns = staticMap!(binaryFun, fun);

        auto cumulativeFold(R)(R range)
        if (isInputRange!(Unqual!R))
        {
            return cumulativeFoldImpl(range);
        }

        auto cumulativeFold(R, S)(R range, S seed)
        if (isInputRange!(Unqual!R))
        {
            static if (fun.length == 1)
                return cumulativeFoldImpl(range, seed);
            else
                return cumulativeFoldImpl(range, seed.expand);
        }

        private auto cumulativeFoldImpl(R, Args...)(R range, ref Args args)
        {
            import std.algorithm.internal : algoFormat;

            static assert(Args.length == 0 || Args.length == fun.length,
                algoFormat("Seed %s does not have the correct amount of fields (should be %s)",
                    Args.stringof, fun.length));

            static if (args.length)
                alias State = staticMap!(Unqual, Args);
            else
                alias State = staticMap!(ReduceSeedType!(ElementType!R), binfuns);

            foreach (i, f; binfuns)
            {
                static assert(!__traits(compiles, f(args[i], e)) || __traits(compiles,
                        { args[i] = f(args[i], e); }()),
                    algoFormat("Incompatible function/seed/element: %s/%s/%s",
                        fullyQualifiedName!f, Args[i].stringof, E.stringof));
            }

            static struct Result
            {
            private:
                R source;
                State state;

                this(R range, ref Args args)
                {
                    source = range;
                    if (source.empty)
                        return;

                    foreach (i, f; binfuns)
                    {
                        static if (args.length)
                            state[i] = f(args[i], source.front);
                        else
                            state[i] = source.front;
                    }
                }

            public:
                @property bool empty()
                {
                    return source.empty;
                }

                @property auto front()
                {
                    assert(!empty, "Attempting to fetch the front of an empty cumulativeFold.");
                    static if (fun.length > 1)
                    {
                        import std.typecons : tuple;
                        return tuple(state);
                    }
                    else
                    {
                        return state[0];
                    }
                }

                void popFront()
                {
                    assert(!empty, "Attempting to popFront an empty cumulativeFold.");
                    source.popFront;

                    if (source.empty)
                        return;

                    foreach (i, f; binfuns)
                        state[i] = f(state[i], source.front);
                }

                static if (isForwardRange!R)
                {
                    @property auto save()
                    {
                        auto result = this;
                        result.source = source.save;
                        return result;
                    }
                }

                static if (hasLength!R)
                {
                    @property size_t length()
                    {
                        return source.length;
                    }
                }
            }

            return Result(range, args);
        }
    }
}

// minElement/maxElement was added in D 2.072.0
static if (__VERSION__ < 2072) {
    private auto extremum(alias map, alias selector = "a < b", Range)(Range r)
    if (isInputRange!Range && !isInfinite!Range &&
        is(typeof(unaryFun!map(ElementType!(Range).init))))
    in
    {
        assert(!r.empty, "r is an empty range");
    }
    body
    {
        alias Element = ElementType!Range;
        Unqual!Element seed = r.front;
        r.popFront();
        return extremum!(map, selector)(r, seed);
    }

    private auto extremum(alias map, alias selector = "a < b", Range,
                          RangeElementType = ElementType!Range)
                         (Range r, RangeElementType seedElement)
    if (isInputRange!Range && !isInfinite!Range &&
        !is(CommonType!(ElementType!Range, RangeElementType) == void) &&
         is(typeof(unaryFun!map(ElementType!(Range).init))))
    {
        alias mapFun = unaryFun!map;
        alias selectorFun = binaryFun!selector;

        alias Element = ElementType!Range;
        alias CommonElement = CommonType!(Element, RangeElementType);
        Unqual!CommonElement extremeElement = seedElement;

        alias MapType = Unqual!(typeof(mapFun(CommonElement.init)));
        MapType extremeElementMapped = mapFun(extremeElement);

        // direct access via a random access range is faster
        static if (isRandomAccessRange!Range)
        {
            foreach (const i; 0 .. r.length)
            {
                MapType mapElement = mapFun(r[i]);
                if (selectorFun(mapElement, extremeElementMapped))
                {
                    extremeElement = r[i];
                    extremeElementMapped = mapElement;
                }
            }
        }
        else
        {
            while (!r.empty)
            {
                MapType mapElement = mapFun(r.front);
                if (selectorFun(mapElement, extremeElementMapped))
                {
                    extremeElement = r.front;
                    extremeElementMapped = mapElement;
                }
                r.popFront();
            }
        }
        return extremeElement;
    }
    private auto extremum(alias selector = "a < b", Range)(Range r)
        if (isInputRange!Range && !isInfinite!Range &&
            !is(typeof(unaryFun!selector(ElementType!(Range).init))))
    {
        alias Element = ElementType!Range;
        Unqual!Element seed = r.front;
        r.popFront();
        return extremum!selector(r, seed);
    }
    private auto extremum(alias selector = "a < b", Range,
                          RangeElementType = ElementType!Range)
                         (Range r, RangeElementType seedElement)
        if (isInputRange!Range && !isInfinite!Range &&
            !is(CommonType!(ElementType!Range, RangeElementType) == void) &&
            !is(typeof(unaryFun!selector(ElementType!(Range).init))))
    {
        alias Element = ElementType!Range;
        alias CommonElement = CommonType!(Element, RangeElementType);
        Unqual!CommonElement extremeElement = seedElement;
        alias selectorFun = binaryFun!selector;

        // direct access via a random access range is faster
        static if (isRandomAccessRange!Range)
        {
            foreach (const i; 0 .. r.length)
            {
                if (selectorFun(r[i], extremeElement))
                {
                    extremeElement = r[i];
                }
            }
        }
        else
        {
            while (!r.empty)
            {
                if (selectorFun(r.front, extremeElement))
                {
                    extremeElement = r.front;
                }
                r.popFront();
            }
        }
        return extremeElement;
    }
    auto minElement(Range)(Range r)
        if (isInputRange!Range && !isInfinite!Range)
    {
        return extremum(r);
    }
    auto minElement(alias map, Range, RangeElementType = ElementType!Range)
                   (Range r, RangeElementType seed)
    if (isInputRange!Range && !isInfinite!Range &&
        !is(CommonType!(ElementType!Range, RangeElementType) == void))
    {
        return extremum!map(r, seed);
    }
    auto minElement(Range, RangeElementType = ElementType!Range)
                   (Range r, RangeElementType seed)
        if (isInputRange!Range && !isInfinite!Range &&
            !is(CommonType!(ElementType!Range, RangeElementType) == void))
    {
        return extremum(r, seed);
    }
    auto maxElement(alias map, Range)(Range r)
    if (isInputRange!Range && !isInfinite!Range)
    {
        return extremum!(map, "a > b")(r);
    }
    auto maxElement(Range)(Range r)
    if (isInputRange!Range && !isInfinite!Range)
    {
        return extremum!`a > b`(r);
    }
    auto maxElement(alias map, Range, RangeElementType = ElementType!Range)
                   (Range r, RangeElementType seed)
    if (isInputRange!Range && !isInfinite!Range &&
        !is(CommonType!(ElementType!Range, RangeElementType) == void))
    {
        return extremum!(map, "a > b")(r, seed);
    }
    auto maxElement(Range, RangeElementType = ElementType!Range)
                   (Range r, RangeElementType seed)
    if (isInputRange!Range && !isInfinite!Range &&
        !is(CommonType!(ElementType!Range, RangeElementType) == void))
    {
        return extremum!`a > b`(r, seed);
    }
}
