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
    int n, m;
    size_t r;
    "%d %d %d\n".readf(&n, &m, &r);

    auto solver = new ChuLiuEdmonds!long(n, r);
    foreach(_; 0..m) {
        size_t s, t;
        long w;
        "%d %d %d\n".readf(&s, &t, &w);
        solver.addEdge(s, t, w);
    }

    solver.solve.writeln;
}

// Chu-Liu/Edmonds' algorithm
class ChuLiuEdmonds(T) {

private:
    size_t _size;
    Vertex[] _vertices;
    Vertex _root;

public:
    this(size_t size, size_t rootIndex) {
        _size = size;
        _vertices = size.iota.map!(i => new Vertex(i)).array;
        _root = _vertices[rootIndex];
    }

    void addEdge(size_t startIndex, size_t endIndex, T weight) {
        if (endIndex == _root.index) return; // rootに入る辺は除外する（最小木に含まれる可能性がないため）
        if (startIndex == endIndex) return; // 自己ループは除外する
        Vertex start = _vertices[startIndex];
        Vertex end   = _vertices[endIndex];
        end.edges ~= Edge(start, end, weight);
    }

    // O(V(V + E)) = O(VE)
    T solve() {
        foreach(v; _vertices) {
            if (!v.hasEdge) continue;
            v.minEdge = v.edges.minElement!"a.weight";
        }

        // v を含む閉路を縮約したグラフの最小コストを返す
        auto rec(Vertex v) {
            auto sub = new ChuLiuEdmonds!T(_size, _root.index);
            auto getIndex  = (Vertex u) => u.onCycle ? v.index : u.index;
            foreach(u; _vertices) {
                foreach(e; u.edges) {
                    sub.addEdge(
                        getIndex(e.start),
                        getIndex(e.end),
                        e.weight - (u.onCycle ? u.minEdge.weight : 0)
                    );
                }
            }
            return sub.solve;
        }

        // 閉路検出
        auto list = DList!Vertex();
        size_t[] cnt = new size_t[_size];
        foreach(v; _vertices) {
            if (v.hasEdge) cnt[v.minEdge.start.index]++;
        }
        foreach(i, c; cnt) {
            if (c==0) list.insertBack(_vertices[i]);
        }
        while(!list.empty) {
            Vertex v = list.front;
            list.removeFront;
            if (v.hasEdge) {
                size_t i = v.minEdge.start.index;
                if (--cnt[i]==0) {
                    list.insertBack(_vertices[i]);
                }
            }
        }
        foreach(i, c; cnt) {
            if (c > 0) {
                // 閉路が検出された
                Vertex v = _vertices[i];
                Vertex u = v;
                do {
                    u.onCycle = true;
                    u = u.minEdge.start;
                } while(u !is v);
                return rec(v) + _vertices.filter!"a.onCycle".map!"a.minEdge.weight".sum;
            }
        }

        // 閉路が検出されなかったとき
        return _vertices.filter!"a.hasEdge".map!"a.minEdge.weight".sum;
    }

private:
    class Vertex {
        size_t index;
        Edge[] edges; // assert(edges.all!(e => e.end is this))
        Edge minEdge;
        bool onCycle = false;
        bool isVisited = false;
        this(size_t index) {
            this.index = index;
        }
        bool hasEdge() {
            return edges.length > 0;
        }
    }

    struct Edge {
        Vertex start, end;
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
