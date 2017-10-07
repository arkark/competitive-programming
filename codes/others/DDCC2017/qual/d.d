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

int H, W;
long A, B;
void main() {
    scanln(H, W);
    scanln(A, B);

    int[][] mat = H.rep!(() => readln.chomp.map!"a=='S'?1:0".array);

    int[] po = new int[H*W/4];
    foreach(i; 0..H/2) foreach(j; 0..W/2) {
        po[i + j*H/2] = mat[i][j] | mat[i][W-j-1]<<1 | mat[H-i-1][j]<<2 | mat[H-i-1][W-j-1]<<3;
    }

    f(
        po.count!"a==0b0101 || a==0b1010".to!int,
        po.count!"a==0b0011 || a==0b1100".to!int,
        po.count!(a => a.popcnt==3).to!int,
        po.count!(a => a.popcnt==4).to!int,
        po.all!(a => a.popcnt!=1) && po.all!"a!=0b1001 && a!=0b0110"
    ).writeln;
}

long f(int x, int y, int z, int w, bool first) {
    return max(g1(x, y, z, w, first), g2(x, y, z, w, first));
}

long g1(int x, int y, int z, int w, bool first = false) {
    if (x==0 && y==0 && z==0) return g3(x, y, z, w, first);
    if (x==0 && z==0) return g2(x, y, z, w, first);
    return value(x, y, z, w, first) + (z>0 ? g1(x, y+1, z-1, w) : g1(x-1, y, z, w));
}

long g2(int x, int y, int z, int w, bool first = false) {
    if (x==0 && y==0 && z==0) return g3(x, y, z, w, first);
    if (y==0 && z==0) return g1(x, y, z, w, first);
    return value(x, y, z, w, first) + (z>0 ? g2(x+1, y, z-1, w) : g2(x, y-1, z, w));
}

long g3(int x, int y, int z, int w, bool first = false) {
    long res = value(x, y, z, w, first);
    if (z>0) {
        res += A>B ? g3(x+1, y, z-1, w) : g3(x, y+1, z-1, w);
    } else if (x>0) {
        res += g3(x-1, y, z, w);
    } else if (y>0) {
        res += g3(x, y-1, z, w);
    } else if (w>0) {
        res += g3(x, y, z+1, w-1);
    }
    return res;
}

long value(int x, int y, int z, int w, bool first = false) {
    long res = 0;
    if (y==0 && z==0) res += A;
    if (x==0 && z==0) res += B;
    return first ? 0 : res;
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
