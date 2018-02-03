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
const double EPS = 1e-8;

void main() {

    int H, M, S;
    scanln(H, M, S);
    H %= 12;
    int T = (H*60 + M)*60 + S;
    int c1, c2;
    scanln(c1, c2);

    int l, r;
    int x1, x2;
    int phase = 0;
    foreach(t1; 0..1000000) {
        int t2 = t1+1;

        vec2 sV1 = getCoord(t1/60.0);
        vec2 mV1 = getCoord(t1/60.0/60.0);
        vec2 hV1 = getCoord(t1/60.0/60.0/12.0);
        vec2 sV2 = getCoord(t2/60.0);
        vec2 mV2 = getCoord(t2/60.0/60.0);
        vec2 hV2 = getCoord(t2/60.0/60.0/12.0);

        bool b1 = mV1.rot(-t1/60.0).sub(sV1.rot(-t1/60.0)).y > -EPS && mV2.rot(-t2/60.0).sub(sV2.rot(-t2/60.0)).y < -EPS;
        bool b2 = hV1.rot(-t1/60.0/60.0).sub(mV1.rot(-t1/60.0/60.0)).y > -EPS && hV2.rot(-t2/60.0/60.0).sub(mV2.rot(-t2/60.0/60.0)).y < -EPS;

        bool a1 = mV1.rot(-t1/60.0).sub(sV1.rot(-t1/60.0)).y.abs < EPS || hV1.rot(-t1/60.0/60.0).sub(mV1.rot(-t1/60.0/60.0)).y.abs < EPS;
        bool a2 = mV2.rot(-t2/60.0).sub(sV2.rot(-t2/60.0)).y.abs < EPS || hV2.rot(-t2/60.0/60.0).sub(mV2.rot(-t2/60.0/60.0)).y.abs < EPS;

        if (phase == 0) {
            if (t1 >= T) {
                phase++;
            }
        }
        if (phase > 0) {
            if (b1) x1++;
            if (b2) x2++;
        }
        if (phase == 1) {
            if (x1==c1 && x2==c2) {
                l = a2 ? t2+1 : t2;
                phase++;
            }
        }
        if (phase == 2) {
            if (x1!=c1 || x2!=c2) {
                r = a1 ? t1-1 : t1;
                phase++;
                break;
            }
        }
    }

    if (phase == 3) {
        writeln(l-T, " ", r-T);
    } else {
        writeln(-1);
    }

}

struct vec2 {
    double x, y;
}
vec2 sub(vec2 v1, vec2 v2) {
    return vec2(v1.x - v2.x, v1.y - v2.y);
}
vec2 getCoord(double t) {
    return vec2(100*cos(t*2*PI), 100*sin(t*2*PI));
}
vec2 rot(vec2 v, double t) {
    double rad = t*2*PI;
    double c = cos(rad);
    double s = sin(rad);
    return vec2(c*v.x - s*v.y, s*v.x + c*v.y);
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
