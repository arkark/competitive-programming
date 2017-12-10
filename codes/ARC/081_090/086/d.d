import std.stdio;
import std.string;
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
import core.bitop : popcnt;
alias Generator = std.concurrency.Generator;

void main() {
    int N; scanln(N);
    long[] as = readln.split.to!(long[]);
    long M = as.reduce!max;
    long m = as.reduce!min;


    size_t[][] ans;
    auto segM = SegTree!(long, (a, b) => a>b ? a:b, long.min)(as);
    auto segm = SegTree!(long, (a, b) => a<b ? a:b, long.max)(as);

    void query(size_t x, size_t y) {
        as[y] += as[x];
        segM.update(y, as[y]);
        segm.update(y, as[y]);
        ans ~= [x, y];
    }

    if (m >= 0 || (M>0 && M>m.abs)) {
        int isSorted1() {
            foreach(int i; 1..N) {
                if (as[i-1]>as[i]) return i;
            }
            return -1;
        }
        while(true) {
            int i = isSorted1();
            if (i<0) break;
            size_t y = i;
            size_t x = segM.queryIndex(0, N);
            query(x, y);
        }
    } else {
        int isSorted2() {
            foreach(int i; iota(1, N).retro) {
                if (as[i-1]>as[i]) return i-1;
            }
            return -1;
        }
        while(true) {
            int i = isSorted2();
            if (i<0) break;
            size_t x = segm.queryIndex(0, N);
            size_t y = i;
            query(x, y);
        }
    }

    ans.length.writeln;
    ans.each!(
        a => writeln(a[0]+1, " ", a[1]+1)
    );
}

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

void scanln(Args...)(ref Args args) {
    foreach(i, ref v; args) {
        "%d".readf(&v);
        (i==args.length-1 ? "\n" : " ").readf;
    }
    // ("%d".repeat(args.length).join(" ") ~ "\n").readf(args);
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
