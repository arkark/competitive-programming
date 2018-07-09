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
const double EPS = 1e-5;

struct Pos {
    double x, y;
    int index;
}
void main() {
    int N;
    scanln(N);
    if (N==2) {
        writeln(0.5);
        writeln(0.5);
        return;
    }
    Pos[] ps = new Pos[N];
    foreach(i; 0..N) {
        scanln(ps[i].x, ps[i].y);
        ps[i].index = i;
    }
    ps = ps.sort!"a.x<b.x".array;

    Pos[] as = ps[0..2].array;
    Pos[] bs = ps[0..2].array;

    foreach(i; 2..N) {
        Pos p = ps[i];
        while(true) {
            if (as.length == 1) {
                as ~= p;
                break;
            }
            Pos q = p.sub(as[$-2]);
            Pos r = as[$-1].sub(as[$-2]);
            double t = cross(q, r);
            double d = q.length - r.length;
            if (t > 0) {
                as = as[0..$-1];
            } else if (t.abs<EPS && d > 0) {
                as = as[0..$-1];
            } else if (t.abs<EPS) {
                break;
            } else {
                as ~= p;
                break;
            }
        }

        while(true) {
            if (bs.length == 1) {
                bs ~= p;
                break;
            }
            Pos q = p.sub(bs[$-2]);
            Pos r = bs[$-1].sub(bs[$-2]);
            double t = cross(q, r);
            double d = q.length - r.length;
            if (t < 0) {
                bs = bs[0..$-1];
            } else if (t.abs<EPS && d > 0) {
                bs = bs[0..$-1];
            } else if (t.abs<EPS) {
                break;
            } else {
                bs ~= p;
                break;
            }
        }
    }

    foreach_reverse(b; bs[1..$-1]) {
        as ~= b;
    }

    int K = as.length.to!int;

    double[] cs = new double[K];
    foreach(i; 0..K) {
        Pos s1 = as[i].sub(as[(i-1+K)%K]);
        Pos s2 = as[(i+1)%K].sub(as[i]);
        s1 = Pos(s1.y, -s1.x);
        s2 = Pos(s2.y, -s2.x);
        double u = atan2(s1.y, s1.x) - atan2(s2.y, s2.x);
        u = fmod(u.abs, 2*PI);
        u = min(u, 2*PI - u);
        cs[i] = u;
    }

    double[] ans = new double[N];
    foreach(i; 0..N) {
        bool flag = false;
        foreach(j; 0..K) {
            if(as[j].index == i) {
                ans[i] = cs[j]/(2*PI);
                flag = true;
                writefln("%0.8f", cs[j]/(2*PI));
                break;
            }
        }
        if (!flag) {
            0.writeln;
        }
    }
}

double lengthSq(Pos a) {
    return a.x*a.x + a.y*a.y;
}

double length(Pos a) {
    return sqrt(a.x*a.x + a.y*a.y);
}

void normalize(ref Pos a) {
    double len = a.length;
    if (len == 0) return;
    a.x /= len;
    a.y /= len;
}

Pos sub(Pos a, Pos b) {
    return Pos(a.x - b.x, a.y - b.y);
}

double cross(Pos a, Pos b) {
    return a.x*b.y - a.y*b.x;
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
