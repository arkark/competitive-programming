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

struct Pos {
    long index;
    long x, y;
}
long dist(Pos p, Pos q) {
    return max(abs(p.x-q.x), abs(p.y-q.y));
}
void main() {
    long N;
    long a, b;
    scanln(N, a, b);
    a--; b--;
    Pos[] ps = N.iota.map!((i){
        long x, y;
        scanln(x, y);
        return Pos(i, x-y, x+y);
    }).array;
    long D = dist(ps[a], ps[b]);

    auto tree1 = redBlackTree!("a.x!=b.x ? a.x<b.x : a.y<b.y", true, Pos)(ps);
    auto tree2 = redBlackTree!("a.y!=b.y ? a.y<b.y : a.x<b.x", true, Pos)(ps);
    tree1.removeKey(ps[a], ps[b]);
    tree2.removeKey(ps[a], ps[b]);

    auto uf = UnionFind(N);
    uf.unite(a, b);
    auto list = DList!Pos(ps[a], ps[b]);
    while(!list.empty) {
        Pos p = list.front;
        list.removeFront;
        auto r1 = tree1.upperBound(Pos(-1, p.x-D, p.y-D-1));
        while (!r1.empty) {
            Pos q = r1.front;
            r1.popFront;
            if (dist(p, q) != D) break;
            list.insertBack(q);
            uf.unite(p.index, q.index);
            tree1.removeKey(q);
            tree2.removeKey(q);
        }
        r1 = tree1.upperBound(Pos(-1, p.x+D, p.y-D-1));
        while (!r1.empty) {
            Pos q = r1.front;
            r1.popFront;
            if (dist(p, q) != D) break;
            list.insertBack(q);
            uf.unite(p.index, q.index);
            tree1.removeKey(q);
            tree2.removeKey(q);
        }

        auto r2 = tree2.upperBound(Pos(-1, p.x-D-1, p.y-D));
        while (!r2.empty) {
            Pos q = r2.front;
            r2.popFront;
            if (dist(p, q) != D) break;
            list.insertBack(q);
            uf.unite(p.index, q.index);
            tree1.removeKey(q);
            tree2.removeKey(q);
        }
        r2 = tree2.upperBound(Pos(-1, p.x-D-1, p.y+D));
        while (!r2.empty) {
            Pos q = r2.front;
            r2.popFront;
            if (dist(p, q) != D) break;
            list.insertBack(q);
            uf.unite(p.index, q.index);
            tree1.removeKey(q);
            tree2.removeKey(q);
        }
    }

    ps = ps.filter!(
        p => uf.same(p.index, a)
    ).array;
    Pos[][] qss1 = ps.dup.sort!"a.x<b.x".chunkBy!"a.x==b.x".map!(
        qs => qs.array.sort!"a.y<b.y".array
    ).array;
    Pos[][] qss2 = ps.dup.sort!"a.y<b.y".chunkBy!"a.y==b.y".map!(
        qs => qs.array.sort!"a.x<b.x".array
    ).array;
    long ans = 0;

    long f(string s)(Pos[] qs, long v) {
        long l = -1, r = qs.length;
        while(r-l>1) {
            long c = (l+r)/2;
            if (c<0) break;
            if (mixin("qs[c]."~s) < v) {
                l = c;
            } else {
                r = c;
            }
        }
        return l;
    }

    foreach(p; ps) {
        {
            // 右側
            auto po = qss1.assumeSorted!(
                (as, bs) => as.front.x<bs.front.x
            ).upperBound([Pos(-1, p.x+D-1, -1)]);
            if (!po.empty) {
                Pos[] qs = po.front;
                if (qs.front.x == p.x+D) {
                    long l = f!"y"(qs, p.y-D);
                    long r = f!"y"(qs, p.y+D+1);
                    ans += max(0, r-l);
                }
            }
        }
        {
            // 左側
            auto po = qss1.assumeSorted!(
                (as, bs) => as.front.x<bs.front.x
            ).upperBound([Pos(-1, p.x-D-1, -1)]);
            if (!po.empty) {
                Pos[] qs = po.front;
                if (qs.front.x == p.x-D) {
                    long l = f!"y"(qs, p.y-D);
                    long r = f!"y"(qs, p.y+D+1);
                    ans += max(0, r-l);
                }
            }
        }
        {
            // 上側
            auto po = qss2.assumeSorted!(
                (as, bs) => as.front.y<bs.front.y
            ).upperBound([Pos(-1, -1, p.y+D-1)]);
            if (!po.empty) {
                Pos[] qs = po.front;
                if (qs.front.y == p.y+D) {
                    long l = f!"x"(qs, p.x-D);
                    long r = f!"x"(qs, p.x+D+1);
                    ans += max(0, r-l);
                }
            }
        }
        {
            // 上側
            auto po = qss2.assumeSorted!(
                (as, bs) => as.front.y<bs.front.y
            ).upperBound([Pos(-1, -1, p.y-D-1)]);
            if (!po.empty) {
                Pos[] qs = po.front;
                if (qs.front.y == p.y-D) {
                    long l = f!"x"(qs, p.x-D);
                    long r = f!"x"(qs, p.x+D+1);
                    ans += max(0, r-l);
                }
            }
        }
        {
            // 右上
            auto po = qss1.assumeSorted!(
                (as, bs) => as.front.x<bs.front.x
            ).upperBound([Pos(-1, p.x+D-1, -1)]);
            if (!po.empty) {
                Pos[] qs = po.front;
                if (qs.front.x == p.x+D) {
                    long l = f!"y"(qs, p.y+D);
                    long r = f!"y"(qs, p.y+D+1);
                    ans -= max(0, r-l);
                }
            }
        }
        {
            // 右下
            auto po = qss1.assumeSorted!(
                (as, bs) => as.front.x<bs.front.x
            ).upperBound([Pos(-1, p.x+D-1, -1)]);
            if (!po.empty) {
                Pos[] qs = po.front;
                if (qs.front.x == p.x+D) {
                    long l = f!"y"(qs, p.y-D);
                    long r = f!"y"(qs, p.y-D+1);
                    ans -= max(0, r-l);
                }
            }
        }
        {
            // 左上
            auto po = qss1.assumeSorted!(
                (as, bs) => as.front.x<bs.front.x
            ).upperBound([Pos(-1, p.x-D-1, -1)]);
            if (!po.empty) {
                Pos[] qs = po.front;
                if (qs.front.x == p.x-D) {
                    long l = f!"y"(qs, p.y+D);
                    long r = f!"y"(qs, p.y+D+1);
                    ans -= max(0, r-l);
                }
            }
        }
        {
            // 左下
            auto po = qss1.assumeSorted!(
                (as, bs) => as.front.x<bs.front.x
            ).upperBound([Pos(-1, p.x-D-1, -1)]);
            if (!po.empty) {
                Pos[] qs = po.front;
                if (qs.front.x == p.x-D) {
                    long l = f!"y"(qs, p.y-D);
                    long r = f!"y"(qs, p.y-D+1);
                    ans -= max(0, r-l);
                }
            }
        }
    }

    writeln(ans/2);
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

mixin template Constructor() {
    import std.traits : FieldNameTuple;
    this(Args...)(Args args) {
        // static foreach(i, v; args) {
        foreach(i, v; args) {
            mixin("this." ~ FieldNameTuple!(typeof(this))[i] ~ "= v;");
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
