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
    int N, M;
    scanln(N, M);

    auto uf = UnionFind(N);

    struct P {
        int l, r; long d;
    }
    P[] ps = new P[M];
    foreach(i; 0..M) {
        scanln(ps[i].l, ps[i].r, ps[i].d);
        ps[i].l--;
        ps[i].r--;
        uf.unite(ps[i].l, ps[i].r);
    }

    P[][] qss = new P[][N];
    foreach(p; ps) {
        assert(uf.findSet(p.l) == uf.findSet(p.r));
        qss[uf.findSet(p.l)] ~= p;
    }

    long[] xs = N.rep!(() => -1L);
    P[][] rss = new P[][N];
    foreach(qs; qss) {
        if (qs.empty) continue;
        foreach(q; qs) {
            rss[q.l] ~= q;
            rss[q.r] ~= q;
        }
        auto list = DList!int(qs.front.l);
        xs[qs.front.l] = 10L^^12;
        while(!list.empty) {
            int s = list.front;
            list.removeFront;
            assert(xs[s] >= 0);
            foreach(r; rss[s]) {
                int t = r.l!=s ? r.l : r.r;
                long x = xs[s] + r.d*(r.l!=s ? 1 : -1);
                if (xs[t]>=0) {
                    if (xs[t] != x) {
                        writeln("No");
                        return;
                    }
                } else {
                    xs[t] = x;
                    list.insertBack(t);
                }
            }
        }
    }
    writeln("Yes");
}


struct UnionFind {

private:
    Vertex[] _vertices;

public:
    this(size_t size) {
        init(size);
    }

    void init(size_t size) {
        _vertices.length = size;
        foreach(i, ref v; _vertices) {
            v.index = i;
            v.parent = i;
        }
    }

    void unite(size_t x, size_t y) {
        link(findSet(x), findSet(y));
    }

    void link(size_t x, size_t y) {
        if (x==y) return;
        if (_vertices[x].rank > _vertices[y].rank) {
            _vertices[y].parent = x;
        } else {
            _vertices[x].parent = y;
            if (_vertices[x].rank == _vertices[y].rank) {
                _vertices[y].rank++;
            }
        }
    }

    bool same(size_t x, size_t y) {
        return findSet(x) == findSet(y);
    }

    size_t findSet(size_t index) {
        if (_vertices[index].parent == index) {
            return index;
        } else {
            return _vertices[index].parent = findSet(_vertices[index].parent);
        }
    }

private:
    struct Vertex {
        size_t index;
        size_t parent;
        size_t rank = 1;
    }
}


// ----------------------------------------------

void scanln(Args...)(auto ref Args args) {
    string getFormat(T)() {
        static if (isIntegral!T) {
            return "%d";
        } else if (isFloatingPoint!T) {
            return "%g";
        } else if (isSomeString!T || isSomeChar!T) {
            return "%s";
        }
        assert(false);
    }
    enum str = {
        string res;
        foreach(i, T; Args) {
            res ~= getFormat!T;
            res ~= i==Args.length-1 ? "\n" : " ";
        }
        return res;
    }();
    // readf!str(args);
    mixin((){
        string res = "str.readf(";
        foreach(i; 0..Args.length) {
            if (i>0) res ~= ", ";
            res ~= "&args[%d]".format(i);
        }
        res ~= ");";
        return res;
    }());
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
