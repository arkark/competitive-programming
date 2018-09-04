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
    long N, M, X;
    scanln(N, M);
    scanln(X);

    Vertex[] vs = N.iota.map!((i) => new Vertex(i)).array;
    Edge[] es = M.iota.map!((i){
        long u, v, w;
        scanln(u, v, w);
        u--; v--;
        Edge e = new Edge(i, vs[u], vs[v], w);
        vs[u].edges ~= e;
        vs[v].edges ~= e;
        return e;
    }).array.sort!"a.weight < b.weight".array;

    auto uf = UnionFind(N);
    foreach(e; es) {
        if (!uf.same(e.start.index, e.end.index)) {
            uf.unite(e.start.index, e.end.index);
            e.used = true;
        }
    }

    long S = es.filter!"a.used".map!"a.weight".sum;
    long D = X - S;

    long[] ds = new long[M];
    foreach(i, edge; es) {
        if (edge.used) {
            ds[i] = -1;
            continue;
        }
        vs.each!(v => v.visited = false);

        long f(Vertex v, Vertex end) {
            if (v is end) return 0;
            v.visited = true;
            foreach(e; v.edges) {
                if (!e.used) continue;
                Vertex u = e.start is v ? e.end : e.start;
                if (u.visited) continue;
                long d = f(u, end);
                if (d >= 0) return max(e.weight, d);
            }
            return -1;
        }
        ds[i] = edge.weight - f(edge.start, edge.end);
        assert(ds[i] >= 0);
    }

    ModNum eq = ModNum(2)^^ds.count!(
        d => d>=0 && d==D
    );
    ModNum gt = ModNum(2)^^ds.count!(
        d => d>=0 && d>D
    );

    if (D<0) {
        writeln(0);
    } else if (D==0) {
        writeln(
            (ModNum(2)^^(N-1) - 2) * (ModNum(2)^^(M-N+1)) + 2*(eq - 1)*gt
        );
    } else {
        writeln(
            2*(eq - 1)*gt
        );
    }
}

class Vertex {
    long index;
    Edge[] edges;
    bool visited;
    mixin Constructor;
}
class Edge {
    long index;
    Vertex start, end;
    long weight;
    long diff;
    bool used = false;
    mixin Constructor;
}



alias ModNum = ModNumber!(long, MOD);

struct ModNumber(T, T mod) if (__traits(isIntegral, T)) {

    T value;
    this(T value) {
        this.value = value;
    }

    ModNumber opAssign(T value) {
        this.value = value;
        return this;
    }

    ModNumber opBinary(string op)(ModNumber that) if (op=="+" || op=="-" || op=="*") {
        return ModNumber(mixin("(this.value "~op~" that.value + mod) % mod"));
    }
    ModNumber opBinary(string op)(T that) if (op=="+" || op=="-" || op=="*") {
        return ModNumber(mixin("(this.value "~op~" that + mod) % mod"));
    }
    ModNumber opBinaryRight(string op)(T that) if (op=="+" || op=="-" || op=="*") {
        return ModNumber(mixin("(that "~op~" this.value + mod) % mod"));
    }

    ModNumber opBinary(string op)(ModNumber that) if (op == "/") {
        return this*getReciprocal(that);
    }
    ModNumber opBinary(string op)(T that) if (op == "/") {
        return this*getReciprocal(ModNumber(that));
    }
    ModNumber opBinaryRight(string op)(T that) if (op == "/") {
        return ModNumber(that)*getReciprocal(this);
    }

    ModNumber opBinary(string op)(ModNumber that) if (op == "^^") {
        return ModNumber(modPow(this.value, that.value));
    }
    ModNumber opBinary(string op)(T that) if (op == "^^") {
        return ModNumber(modPow(this.value, that));
    }
    ModNumber opBinaryRight(string op)(T that) if (op == "^^") {
        return ModNumber(modPow(that, this.value));
    }

    void opOpAssign(string op)(ModNumber that) if (op=="+" || op=="-" || op=="*" || op=="/") {
        this = mixin("this" ~op~ "that");
    }
    void opOpAssign(string op)(T that) if (op=="+" || op=="-" || op=="*" || op=="/") {
        this = mixin("this" ~op~ "that");
    }

    ModNumber getReciprocal(ModNumber x) in {
        debug assert(isPrime(mod));
    } body {
        return ModNumber(modPow(x.value, mod-2));
    }
    T modPow(T base, T power)  {
        T result = 1;
        for (; power > 0; power >>= 1) {
            if (power & 1) {
                result = (result * base) % mod;
            }
            base = base*base % mod;
        }
        return result;
    }

    string toString() {
        import std.conv;
        return this.value.to!string;
    }

    invariant {
        assert(this.value>=0);
        assert(this.value<mod);
    }

    private bool isPrime(T n) {
        if (n<2) {
            return false;
        } else if (n==2) {
            return true;
        } else if (n%2==0) {
            return false;
        } else {
            for(T i=3; i*i<=n; i+=2) {
                if (n%i==0) return false;
            }
            return true;
        }
    }
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
