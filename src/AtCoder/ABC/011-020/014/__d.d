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
    int N;
    scanln(N);

    auto lca = LCA(N);
    (N-1).times!({
        int x, y;
        scanln(x, y);
        x--; y--;
        lca.addEdge(x, y);
    });

    int Q;
    scanln(Q);
    Q.times!({
        int a, b;
        scanln(a, b);
        a--; b--;
        int depthA = lca.getDepth(a);
        int depthB = lca.getDepth(b);
        int depthC = lca.queryDepth(a, b);
        writeln((depthA - depthC) + (depthB - depthC) + 1);
    });
}


// Lowest Common Ancestor by Doubling Technique
struct LCA {

private:
    size_t _size;
    size_t _logSize;
    Vertex[] _vertices;
    size_t _rootIndex;
    bool _builded;

public:

    this(size_t size) {
        _size = size;
        _logSize = cast(size_t)(log2(_size) + 2);
        _vertices.length = _size;
        foreach(i, ref v; _vertices) {
            _vertices[i] = new Vertex;
            _vertices[i].index = i;
            _vertices[i].powParents.length = _logSize;
        }
        _rootIndex = 0;
        _builded = false;
    }

    // O(1)
    void addEdge(size_t x, size_t y) {
        _builded = false;
        Vertex vx = _vertices[x];
        Vertex vy = _vertices[y];
        vx.edges ~= Edge(vx, vy);
        vy.edges ~= Edge(vy, vx);
    }

    // O(1)
    void setRoot(size_t index) {
        _builded = false;
        _rootIndex = index;
    }

    // O(log N)
    size_t queryIndex(size_t x, size_t y) {
        return queryVertex(x, y).index;
    }

    // O(log N)
    int queryDepth(size_t x, size_t y) {
        return queryVertex(x, y).depth;
    }

    // O(1)
    int getDepth(size_t x) {
        // return queryDepth(x, x);
        if (!_builded) build();
        return _vertices[x].depth;
    }

private:

    // O(N log N)
    void build() {
        _vertices.each!(v => v.visited = false);

        void dfs(Vertex vertex, Vertex parent, int depth) {
            vertex.powParents[0] = parent;
            vertex.depth = depth;
            foreach(v; vertex.edges.map!"a.end") {
                if (v.visited) continue;
                v.visited = true;
                dfs(v, vertex, depth + 1);
            }
        }
        _vertices[_rootIndex].visited = true;
        dfs(_vertices[_rootIndex], null, 0);

        foreach(k; 1.._logSize) {
            foreach(v; _vertices) {
                if (v.powParents[k-1] is null) continue;
                v.powParents[k] = v.powParents[k-1].powParents[k-1];
            }
        }

        _builded = true;
    }

    Vertex queryVertex(size_t x, size_t y) {
        if (!_builded) build();

        Vertex vx = _vertices[x];
        Vertex vy = _vertices[y];

        if (vx.depth > vy.depth) swap(vx, vy);
        foreach(k; 0.._logSize) {
            if ((vy.depth - vx.depth)>>k&1) {
                vy = vy.powParents[k];
                assert(vy !is null);
            }
        }
        assert(vx.depth == vy.depth);
        if (vx is vy) return vx;

        foreach(k; _logSize.iota.retro) {
            if (vx.powParents[k] !is vy.powParents[k]) {
                vx = vx.powParents[k];
                vy = vy.powParents[k];
                assert(vx !is null && vy !is null);
            }
        }
        assert(vx.powParents[0] is vy.powParents[0]);

        return vx.powParents[0];
    }

    class Vertex {
        size_t index;
        int depth;
        bool visited;
        Vertex[] powParents; // powParents[i][j] = 頂点iから2^j回親を辿った頂点（いなければnull）
        Edge[] edges;
    }

    struct Edge {
        Vertex start, end;
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
