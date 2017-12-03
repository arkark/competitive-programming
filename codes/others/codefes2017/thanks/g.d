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
    int N, M;
    scanln(N, M);

    int[][] isUnited = new int[][](N, N);
    foreach(_; 0..M) {
        int a, b;
        scanln(a, b);
        a--; b--;
        isUnited[a][b] = 1;
        isUnited[b][a] = 1;
    }

    int[] isIndependentSet1 = new int[1<<N/2];
    isIndependentSet1[] = 1;
    foreach(i; 0..N/2) foreach(j; 0..i) {
        isIndependentSet1[1<<i | 1<<j] = ~isUnited[i][j];
    }
    foreach(i; 0..N/2) {
        foreach(bits; 0..1<<N/2) {
            if ((bits&1<<i) == 0) {
                isIndependentSet1[bits|1<<i] &= isIndependentSet1[bits];
            }
        }
    }

    int[] toMaximumSet = new int[1<<N/2];
    toMaximumSet[] = (1<<(N-N/2))-1;
    foreach(i; 0..N/2) {
        int bits = (1<<(N-N/2))-1;
        foreach(j; 0..N-N/2) {
            bits &= ~(isUnited[i][j+N/2]<<j);
        }
        toMaximumSet[1<<i] = bits;
    }
    foreach(i; 0..N/2) {
        foreach(bits; 0..1<<N/2) {
            if ((bits&1<<i) == 0) {
                toMaximumSet[bits|1<<i] &= toMaximumSet[bits] & toMaximumSet[1<<i];
            }
        }
    }

    int[] isIndependentSet2 = new int[1<<(N-N/2)];
    isIndependentSet2[] = 1;
    foreach(i; 0..N-N/2) foreach(j; 0..i) {
        isIndependentSet2[1<<i | 1<<j] = ~isUnited[i+N/2][j+N/2];
    }
    foreach(i; 0..N-N/2) {
        foreach(bits; 0..1<<(N-N/2)) {
            if ((bits&1<<i) == 0) {
                isIndependentSet2[bits|1<<i] &= isIndependentSet2[bits];
            }
        }
    }

    int[] toMaximumIndependentSetSize = (1<<(N-N/2)).iota.map!(
        bits => isIndependentSet2[bits] ? bits.popcnt : 0
    ).array;
    foreach(i; 0..N-N/2) {
        foreach(bits; 0..1<<(N-N/2)) {
            if ((bits&1<<i) == 0) {
                toMaximumIndependentSetSize[bits|1<<i] = max(toMaximumIndependentSetSize[bits|1<<i], toMaximumIndependentSetSize[bits]);
            }
        }
    }

    (1<<N/2).iota.filter!(
        bits => isIndependentSet1[bits]
    ).map!(
        bits => bits.popcnt + toMaximumIndependentSetSize[toMaximumSet[bits]]
    ).reduce!max.writeln;

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
