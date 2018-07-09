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

void main() {
    long N;
    scanln(N);
    long[] as = readln.split.to!(long[]);

    /*
     Project Selection Problem
       - 集合A -> 集合B
       - 要素iがAに属するときに利益-as[i]を得る
       - 要素iと要素j = (i+1)n-1 (n ∈ ℕ)に対し
         - iがAに属し、jがBに属していたときに∞の損失
    */
    auto solver = MaxFlow(N+2);
    long s = N;
    long t = N+1;
    foreach(i, a; as) {
        if (-a>0) {
            solver.addEdge(s, i, -a);
        } else {
            solver.addEdge(i, t, a);
        }
    }
    foreach(i; 0..N) {
        foreach(_j; 2..long.max) {
            long j = (i+1)*_j-1;
            if (j >= N) break;
            solver.addEdge(i, j, INF);
        }
    }
    long psp = as.map!"-a".filter!"a>=0".sum - solver.solve(s, t);
    writeln(as.sum + psp);
}

// maximum flow problem
//   Dinic's algorithm O(VE^2)

struct MaxFlow {
    Vertex[] vertices;

public:
    this(size_t size) {
        vertices.length = size;
        foreach(ref v; vertices) v = new Vertex;
    }

    void addEdge(size_t start, size_t end, long capacity) {
        Edge e1 = new Edge(vertices[start], vertices[end], capacity);
        Edge e2 = new Edge(vertices[end], vertices[start], 0);
        e1.revEdge = e2;
        e2.revEdge = e1;
        vertices[start].edges ~= e1;
        vertices[end].edges ~= e2;
    }

    long solve(size_t s, size_t t) {
        long flow = 0;
        foreach(v; vertices) {
            foreach(e; v.edges) {
                e.capacity = e.initCapacity;
            }
        }
        while(true) {
            bfs(vertices[s]);
            if (vertices[t].level < 0) break;
            foreach(v; vertices) v.iter = 0;
            long f = 0;
            while((f = dfs(vertices[s], vertices[t], INF)) > 0) {
                flow += f;
            }
        }
        return flow;
    }

private:
    void bfs(Vertex s) {
        import std.container : DList;
        foreach(v; vertices) v.level = -1;
        s.level = 0;
        auto list = DList!Vertex(s);
        while(!list.empty) {
            Vertex v = list.front;
            list.removeFront;
            foreach(e; v.edges) {
                if (e.capacity<=0 || e.end.level>=0) continue;
                e.end.level = e.start.level + 1;
                list.insertBack(e.end);
            }
        }
    }

    long dfs(Vertex v, Vertex t, long f) {
        if (v is t) return f;
        foreach(i; v.iter..v.edges.length) {
            v.iter = i;
            Edge e = v.edges[i];
            if (e.capacity<=0 || e.end.level<=e.start.level) continue;
            long d = dfs(e.end, t, min(f, e.capacity));
            if (d > 0) {
                e.capacity -= d;
                e.revEdge.capacity += d;
                return d;
            }
        }
        return 0;
    }

    class Vertex {
        long level;
        long iter;
        Edge[] edges;
    }
    class Edge {
        Vertex start, end;
        long initCapacity;
        long capacity;
        Edge revEdge;
        this(Vertex start, Vertex end, long capacity) {
            this.start = start;
            this.end = end;
            this.initCapacity = capacity;
        }
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
