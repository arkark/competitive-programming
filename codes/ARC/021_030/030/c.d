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
    long N, M, K;
    scanln(N, M, K);
    Vertex[] vs = readln.split.map!(to!char).map!(c => new Vertex(c)).array;
    Edge[] es = M.rep!({
        long a, b;
        scanln(a, b);
        a--; b--;
        return Edge(vs[a], vs[b]);
    });
    foreach(e; es) {
        e.start.toVertices ~= e.end;
        e.end.fromVertices ~= e.start;
    }

    // 強連結成分分解
    long dfs(Vertex v, long rank) {
        v.used = true;
        foreach(u; v.toVertices) {
            if (u.used) continue;
            u.used = true;
            rank = dfs(u, rank);
        }
        v.rank = rank++;
        return rank;
    }
    void rdfs(Vertex v, ref DList!Vertex list) {
        v.used = true;
        list.insertBack(v);
        foreach(u; v.fromVertices) {
            if (u.used) continue;
            rdfs(u, list);
        }
    }
    vs.each!(v => v.used = false);
    long rank = 0;
    foreach(v; vs) {
        if (v.used) continue;
        rank = dfs(v, rank);
    }
    vs.each!(v => v.used = false);
    Component[] components;
    foreach(v; vs.sort!"a.rank>b.rank") {
        if (v.used) continue;
        auto list = DList!Vertex();
        rdfs(v, list);
        Component component = new Component(list[].array);
        foreach(u; component.vertices) u.component = component;
        components ~= component;
    }
    // 強連結成分分解ここまで

    // DP
    string inf = 'z'.repeat(K+1).to!string;
    foreach(c; components) {
        c.str = c.vertices.map!"a.c".map!(to!string).array.sort!"a<b".join.to!string;
        c.dp = (K+1).rep!(()=>inf);
        foreach(i; 0..min(K, c.str.length)+1) {
            c.dp[i] = c.str[0..i];
        }
    }
    foreach(i; 0..K+1) {
        foreach(e; es) {
            Component c1 = e.start.component;
            Component c2 = e.end.component;
            if (c1 is c2) continue;
            foreach(j; 0..i+1) {
                if (i-j > c2.str.length) continue;
                c2.dp[i] = min(c2.dp[i], c1.dp[j] ~ c2.str[0..i-j]);
            }
        }
    }
    string ans = components.map!(c => c.dp.back).reduce!min;
    if (ans == inf) {
        writeln(-1);
    } else {
        ans.writeln;
    }
}

class Vertex {
    char c;
    Vertex[] toVertices;
    Vertex[] fromVertices;
    bool used;
    long rank;
    Component component; // 所属する強連結成分
    this(char c) {
        this.c = c;
    }
}

struct Edge {
    Vertex start, end;
}

class Component {
    Vertex[] vertices;
    string[] dp;
    string str;
    this(Vertex[] vertices) {
        this.vertices = vertices;
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
