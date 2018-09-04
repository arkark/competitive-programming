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

void main() {
    int N = readln.chomp.to!int;

    struct P{size_t index; long x, y;}
    P[] ps = N.iota.map!((i) {
        long x, y;
        "%d %d\n".readf(&x, &y);
        x--; y--;
        return P(i, x, y);
    }).array;

    auto prim = Prim!long(N);

    ps.sort!"a.x<b.x".array.repeat(2).enumerate.map!(
        a => a.value[a.index..$-1+a.index]
    ).pipe!(
        a => zip(a.front, a.back)
    ).each!(
        a => prim.addEdge(a[0].index, a[1].index, a[1].x - a[0].x)
    );
    ps.sort!"a.y<b.y".array.repeat(2).enumerate.map!(
        a => a.value[a.index..$-1+a.index]
    ).pipe!(
        a => zip(a.front, a.back)
    ).each!(
        a => prim.addEdge(a[0].index, a[1].index, a[1].y - a[0].y)
    );

    prim.solve.writeln;
}

struct Prim(T, T inf = T.max) {

private:
    Vertex[] _vertices;

public:
    this(size_t size) {
        _vertices.length = size;
        foreach(i; 0..size) {
            _vertices[i] = new Vertex(i);
        }
    }

    void addEdge(size_t start, size_t end, T weight) {
        _vertices[start].edges ~= Edge(start, end, weight);
        _vertices[end].edges   ~= Edge(end, start, weight);
    }

    T solve() {
        _vertices.front.cost = 0;
        auto tree = redBlackTree!(
            "a.cost==b.cost ? a.index<b.index : a.cost<b.cost",
            true,
            Vertex
        )(_vertices.front);
        while(!tree.empty) {
            Vertex v = tree.front;
            v.used = true;
            tree.removeFront;
            v.edges.each!((Edge e) {
                if (_vertices[e.end].used) return;
                tree.removeKey(_vertices[e.end]);
                _vertices[e.end].cost = min(_vertices[e.end].cost, e.weight);
                tree.insert(_vertices[e.end]);
            });
        }
        return _vertices.map!"a.cost".sum;
    }

private:
    class Vertex {
        size_t index;
        bool used;
        T cost = inf;
        Edge[] edges;
        this(size_t index) {
            this.index = index;
        }
        override string toString() {return "";} //
    }
    struct Edge {
        size_t start;
        size_t end;
        T weight;
    }
}


// ----------------------------------------------

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
