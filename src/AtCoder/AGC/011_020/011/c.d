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

const long INF = long.max/3;
const long MOD = 10L^^9+7;

void main() {
    int N, M;
    scanln(N, M);
    Vertex[] vs = N.rep!(() => new Vertex);
    foreach(_; 0..M) {
        int u, v;
        scanln(u, v);
        u--; v--;
        vs[u].edges ~= Edge(vs[u], vs[v]);
        vs[v].edges ~= Edge(vs[v], vs[u]);
    }
    long componentCnt1, nodeCnt1; // isolated vertices
    long componentCnt2, nodeCnt2; // non-bipartite components
    long componentCnt3, nodeCnt3; // bipartite components
    vs.each!((v) {
        if (v.used) return;
        bool isBipartite = true;
        long cnt = 0;
        v.used = true;
        v.isEven = true;
        auto list = DList!Vertex(v);
        while(!list.empty) {
            cnt++;
            Vertex u1 = list.front;
            list.removeFront;
            u1.edges.map!"a.end".each!((u2) {
                isBipartite &= !u2.used || (u1.isEven != u2.isEven);
                if (u2.used) return;
                u2.used = true;
                u2.isEven = !u1.isEven;
                list.insertBack(u2);
            });
        }
        if (cnt == 1) {
            componentCnt1++;
            nodeCnt1 += cnt;
        } else if (!isBipartite) {
            componentCnt2++;
            nodeCnt2 += cnt;
        } else {
            componentCnt3++;
            nodeCnt3 += cnt;
        }
    });

    long ans = 0;
    ans += componentCnt1*componentCnt1;
    ans += 2*componentCnt1*(nodeCnt2 + nodeCnt3);
    ans += componentCnt2*componentCnt2;
    ans += 2*componentCnt2*componentCnt3;
    ans += 2*componentCnt3*componentCnt3;
    ans.writeln;
}

class Vertex {
    Edge[] edges;
    bool used = false;
    bool isEven;
}
struct Edge {
    Vertex start, end;
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
