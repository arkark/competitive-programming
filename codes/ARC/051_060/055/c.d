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
import std.ascii;
import std.concurrency;
import std.traits;
import core.bitop : popcnt;
alias Generator = std.concurrency.Generator;

const long INF = long.max/3;
const long MOD = 10L^^9+7;

void main() {
    string str = readln.chomp;
    int N = str.length.to!int;

    int[] f(string s) {
        int[] suffixArray = s.getSuffixArray;
        int[] lcpArray = s.getLCPArray(suffixArray);
        auto rmq = RMQ!int(lcpArray);

        int[] ranks = new int[N+1];
        foreach(i; 0..N+1) ranks[suffixArray[i]] = i;

        return iota(0, N+1).map!((i) {
            int x = ranks[0];
            int y = ranks[i];
            if (x > y) swap(x, y);
            return min(N, rmq.query(x, y));
        }).array;
    }

    zip(f(str), f(str.retro.to!string).retro.array).enumerate.map!(
        (po) {
            long n = N-po.index.to!int;
            if (2*n >= N) return 0L;
            long a = min(n-1, po.value[0]);
            long c = min(n-1, po.value[1]);
            if (a<=0 || c<=0) return 0L;
            return max(0L, a+c-n+1L);
        }
    ).sum.writeln;
}

// Suffix Array (Manber & Myers algorithm)
//   O(n (log n)^2)
int[] getSuffixArray(T)(T[] xs) in {
    assert(xs.all!"a>=0");
} body {
    int n = xs.length.to!int;

    int[] suffixArray = new int[n+1];
    int[] ranks = new int[n+1];
    int[] temps = new int[n+1];

    foreach(i; 0..n+1) {
        suffixArray[i] = i;
        ranks[i] = i<n ? xs[i].to!int : -1;
    }

    int k;
    bool compare(int i, int j) {
        if (ranks[i] != ranks[j]) {
            return ranks[i] < ranks[j];
        } else {
            return (i+k<=n ? ranks[i+k] : -1) < (j+k<=n ? ranks[j+k] : -1);
        }
    }

    for(k=1; k<=n; k*=2) {
        suffixArray = suffixArray.sort!compare.array;
        temps[suffixArray[0]] = 0;
        foreach(i; 1..n+1) {
            temps[suffixArray[i]] = temps[suffixArray[i-1]] + (compare(suffixArray[i-1], suffixArray[i]) ? 1 : 0);
        }
        ranks[] = temps[];
    }

    return suffixArray;
}

// Longest Common Prefix Array (LCP Array)
//   O(n)
//   @required Suffix Array
int[] getLCPArray(T)(T[] xs, int[] suffixArray) {
    int n = xs.length.to!int;
    assert(n+1 == suffixArray.length);

    int[] ranks = new int[n+1];
    foreach(i; 0..n+1) ranks[suffixArray[i]] = i;

    int[] lcpArray = new int[n];
    int len = 0;
    lcpArray[0] = 0;
    foreach(i; 0..n) {
        int j = suffixArray[ranks[i] - 1];

        if (len > 0) len--;
        while(true) {
            if (i+len >= n) break;
            if (j+len >= n) break;
            if (xs[i+len] != xs[j+len]) break;
            len++;
        }

        lcpArray[ranks[i] - 1] = len;
    }

    return lcpArray;
}

unittest {
    string xs = "abracadabra";
    int[] suffixArray = xs.getSuffixArray;
    int[] lcpArray = xs.getLCPArray(suffixArray);

    /*
     Suffix Array and LCP Array of "abracadabra":
      11: ""            - 0
      10: "a"           - 1
       7: "abra"        - 4
       0: "abracadabra" - 1
       3: "acadabra"    - 1
       5: "adabra"      - 0
       8: "bra"         - 3
       1: "bracadabra"  - 0
       4: "cadabra"     - 0
       6: "dabra"       - 0
       9: "ra"          - 2
       2: "racadabra"   - _
    */

    assert(suffixArray == [11, 10, 7, 0, 3, 5, 8, 1, 4, 6, 9, 2]);
    assert(lcpArray == [0, 1, 4, 1, 1, 0, 3, 0, 0, 0, 2]);
}

// RMQ (Range Minimum Query)
alias RMQ(T) = SegTree!(T, (a, b) => a<b ? a:b, T.max);

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



// ----------------------------------------------

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

void times(alias fun)(int n) {
    // n.iota.each!(i => fun());
    foreach(i; 0..n) fun();
}
auto rep(alias fun, T = typeof(fun()))(int n) {
    // return n.iota.map!(i => fun()).array;
    T[] res = new T[n];
    foreach(ref e; res) e = fun();
    return res;
}

T ceil(T)(T x, T y) if (__traits(isIntegral, T)) {
    // `(x+y-1)/y` will only work for positive numbers ...
    T t = x / y;
    if (t * y < x) t++;
    return t;
}

T floor(T)(T x, T y) if (__traits(isIntegral, T)) {
    T t = x / y;
    if (t * y > x) t--;
    return t;
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
    auto minElement(alias map, Range)(Range r)
    if (isInputRange!Range && !isInfinite!Range)
    {
        alias mapFun = unaryFun!map;
        auto element = r.front;
        auto minimum = mapFun(element);
        r.popFront;
        foreach(a; r) {
            auto b = mapFun(a);
            if (b < minimum) {
                element = a;
                minimum = b;
            }
        }
        return element;
    }
    auto maxElement(alias map, Range)(Range r)
    if (isInputRange!Range && !isInfinite!Range)
    {
        alias mapFun = unaryFun!map;
        auto element = r.front;
        auto maximum = mapFun(element);
        r.popFront;
        foreach(a; r) {
            auto b = mapFun(a);
            if (b > maximum) {
                element = a;
                maximum = b;
            }
        }
        return element;
    }
}
