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

int H, W, D, K;
Pos[] ps;
void main() {
    scanln(H, W, D, K);
    ps.length = D;
    foreach(i; 0..D) {
        int y, x;
        scanln(y, x);
        ps[i].y = y;
        ps[i].x = x;
    }

    Swap[] swaps = new Swap[K];

    import std.random;
    auto rnd = Random(unpredictableSeed);

    int k = 0;

    long s0 = 0;
    foreach(j; 1..D) {
        s0 += dist(ps[j-1], ps[j]);
    }
    foreach(i; 0..K) {
        long maxDiff = 0;
        int maxJ1 = -1;
        int maxJ2 = -1;

        long s1 = s0;
        // foreach(j1; 0..D) foreach(j2; 0..D) {
        foreach(_; 0..13000) {
            int j1 = uniform(0, D, rnd);
            int j2 = uniform(0, D, rnd);
            if (j1 == j2) continue;
            if (j1 > j2) swap(j1, j2);

            long s2 = s1;
            if (j1 > 0) s2 -= dist(ps[j1-1], ps[j1]);
            if (j1 < D-1) s2 -= dist(ps[j1], ps[j1+1]);
            if (j1 > 0) s2 += dist(ps[j1-1], ps[j2]);
            if (j1 < D-1) s2 += dist(ps[j2], ps[j1+1]);
            if (j2 > 0) s2 -= dist(ps[j2-1], ps[j2]);
            if (j2 < D-1) s2 -= dist(ps[j2], ps[j2+1]);
            if (j2 > 0) s2 += dist(ps[j2-1], ps[j1]);
            if (j2 < D-1) s2 += dist(ps[j1], ps[j2+1]);

            long diff = s1 - s2;
            if (diff > maxDiff) {
                maxDiff = diff;
                maxJ1 = j1;
                maxJ2 = j2;
            }
        }

        if (maxJ1 < 0) {
            break;
        }

        swaps[k] = Swap(ps[maxJ1], ps[maxJ2]);
        swap(ps[maxJ1], ps[maxJ2]);
        s0 = s1 - maxDiff;

        k++;
    }

    swaps[0..k].map!(a => "%d %d %d %d".format(a.p1.y, a.p1.x, a.p2.y, a.p2.x)).each!writeln;

}

struct Pos {
    int y, x;
}

struct Swap {
    Pos p1, p2;
}

int dist(Pos p1, Pos p2) {
    return abs(p1.y - p2.y) + abs(p1.x - p2.x);
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
