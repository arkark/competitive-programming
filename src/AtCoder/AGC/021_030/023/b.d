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
    char[][] css = N.rep!(() => readln.chomp.to!(char[]));
    char[][] dss = new char[][](N, N);

    long ans = 0;
    foreach(i; 0..N) {
        foreach(j; 0..N) {
            dss[j][] = css[(j+i)%$][];
        }
        bool ok = true;
        foreach(j; 0..N) foreach(k; 0..N) {
            ok &= dss[j][k] == dss[k][j];
        }
        if (ok) ans += N;
    }
    ans.writeln;
}

// ----------------------------------------------

mixin template Constructor() {
    import std.traits : FieldNameTuple;
    this(Args...)(Args args) {
        // static foreach(i, v; args) {
        foreach(i, v; args) {
            mixin("this." ~ FieldNameTuple!(typeof(this))[i]) = v;
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

T ceil(T)(T x, T y) if (isIntegral!T || is(T == BigInt)) {
    // `(x+y-1)/y` will only work for positive numbers ...
    T t = x / y;
    if (t * y < x) t++;
    return t;
}

T floor(T)(T x, T y) if (isIntegral!T || is(T == BigInt)) {
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
    private auto extremum(alias map, alias selector = "a < b", Range)(Range r)
    if (isInputRange!Range && !isInfinite!Range &&
        is(typeof(unaryFun!map(ElementType!(Range).init))))
    in
    {
        assert(!r.empty, "r is an empty range");
    }
    body
    {
        alias Element = ElementType!Range;
        Unqual!Element seed = r.front;
        r.popFront();
        return extremum!(map, selector)(r, seed);
    }

    private auto extremum(alias map, alias selector = "a < b", Range,
                          RangeElementType = ElementType!Range)
                         (Range r, RangeElementType seedElement)
    if (isInputRange!Range && !isInfinite!Range &&
        !is(CommonType!(ElementType!Range, RangeElementType) == void) &&
         is(typeof(unaryFun!map(ElementType!(Range).init))))
    {
        alias mapFun = unaryFun!map;
        alias selectorFun = binaryFun!selector;

        alias Element = ElementType!Range;
        alias CommonElement = CommonType!(Element, RangeElementType);
        Unqual!CommonElement extremeElement = seedElement;

        alias MapType = Unqual!(typeof(mapFun(CommonElement.init)));
        MapType extremeElementMapped = mapFun(extremeElement);

        // direct access via a random access range is faster
        static if (isRandomAccessRange!Range)
        {
            foreach (const i; 0 .. r.length)
            {
                MapType mapElement = mapFun(r[i]);
                if (selectorFun(mapElement, extremeElementMapped))
                {
                    extremeElement = r[i];
                    extremeElementMapped = mapElement;
                }
            }
        }
        else
        {
            while (!r.empty)
            {
                MapType mapElement = mapFun(r.front);
                if (selectorFun(mapElement, extremeElementMapped))
                {
                    extremeElement = r.front;
                    extremeElementMapped = mapElement;
                }
                r.popFront();
            }
        }
        return extremeElement;
    }
    private auto extremum(alias selector = "a < b", Range)(Range r)
        if (isInputRange!Range && !isInfinite!Range &&
            !is(typeof(unaryFun!selector(ElementType!(Range).init))))
    {
        alias Element = ElementType!Range;
        Unqual!Element seed = r.front;
        r.popFront();
        return extremum!selector(r, seed);
    }
    private auto extremum(alias selector = "a < b", Range,
                          RangeElementType = ElementType!Range)
                         (Range r, RangeElementType seedElement)
        if (isInputRange!Range && !isInfinite!Range &&
            !is(CommonType!(ElementType!Range, RangeElementType) == void) &&
            !is(typeof(unaryFun!selector(ElementType!(Range).init))))
    {
        alias Element = ElementType!Range;
        alias CommonElement = CommonType!(Element, RangeElementType);
        Unqual!CommonElement extremeElement = seedElement;
        alias selectorFun = binaryFun!selector;

        // direct access via a random access range is faster
        static if (isRandomAccessRange!Range)
        {
            foreach (const i; 0 .. r.length)
            {
                if (selectorFun(r[i], extremeElement))
                {
                    extremeElement = r[i];
                }
            }
        }
        else
        {
            while (!r.empty)
            {
                if (selectorFun(r.front, extremeElement))
                {
                    extremeElement = r.front;
                }
                r.popFront();
            }
        }
        return extremeElement;
    }
    auto minElement(Range)(Range r)
        if (isInputRange!Range && !isInfinite!Range)
    {
        return extremum(r);
    }
    auto minElement(alias map, Range, RangeElementType = ElementType!Range)
                   (Range r, RangeElementType seed)
    if (isInputRange!Range && !isInfinite!Range &&
        !is(CommonType!(ElementType!Range, RangeElementType) == void))
    {
        return extremum!map(r, seed);
    }
    auto minElement(Range, RangeElementType = ElementType!Range)
                   (Range r, RangeElementType seed)
        if (isInputRange!Range && !isInfinite!Range &&
            !is(CommonType!(ElementType!Range, RangeElementType) == void))
    {
        return extremum(r, seed);
    }
    auto maxElement(alias map, Range)(Range r)
    if (isInputRange!Range && !isInfinite!Range)
    {
        return extremum!(map, "a > b")(r);
    }
    auto maxElement(Range)(Range r)
    if (isInputRange!Range && !isInfinite!Range)
    {
        return extremum!`a > b`(r);
    }
    auto maxElement(alias map, Range, RangeElementType = ElementType!Range)
                   (Range r, RangeElementType seed)
    if (isInputRange!Range && !isInfinite!Range &&
        !is(CommonType!(ElementType!Range, RangeElementType) == void))
    {
        return extremum!(map, "a > b")(r, seed);
    }
    auto maxElement(Range, RangeElementType = ElementType!Range)
                   (Range r, RangeElementType seed)
    if (isInputRange!Range && !isInfinite!Range &&
        !is(CommonType!(ElementType!Range, RangeElementType) == void))
    {
        return extremum!`a > b`(r, seed);
    }
}
