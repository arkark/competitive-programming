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

void main() {
    int N, M, A, B;
    scanln(N, M, A, B);
    if (f(N, M, A, B)) return;
    if (g(N, M, A, B)) return;
    "NO".writeln;
}

bool f(int N, int M, int A, int B) {
    char[][] ans = new char[][](N, M);
    foreach(i; 0..N) foreach(j; 0..M) ans[i][j] = '.';
    if (N%2==1) {
        foreach(j; 0..M/2) {
            if (A == 0) break;
            ans[$-1][2*j+0] = '<';
            ans[$-1][2*j+1] = '>';
            A--;
        }
    }
    if (M%2==1) {
        foreach(i; 0..N/2) {
            if (B == 0) break;
            ans[2*i+0][$-1] = '^';
            ans[2*i+1][$-1] = 'v';
            B--;
        }
    }
    foreach(i; 0..(N/2)*(M/2)) {
        int y = i/(M/2)*2;
        int x = i%(M/2)*2;
        if (A>0) {
            if (A>0) ans[y+0][x+0] = '<';
            if (A>0) ans[y+0][x+1] = '>';
            if (A>0) A--;
            if (A>0) ans[y+1][x+0] = '<';
            if (A>0) ans[y+1][x+1] = '>';
            if (A>0) A--;
        } else if (B>0) {
            if (B>0) ans[y+0][x+0] = '^';
            if (B>0) ans[y+1][x+0] = 'v';
            if (B>0) B--;
            if (B>0) ans[y+0][x+1] = '^';
            if (B>0) ans[y+1][x+1] = 'v';
            if (B>0) B--;
        }
    }
    if (A==0 && B==0) {
        "YES".writeln;
        ans.each!writeln;
        return true;
    }
    return false;
}

bool g(int N, int M, int A, int B) {
    if (N*M%2==0) return false;
    if (N<3 || M<3) return false;

    char[][] ans = new char[][](N, M);
    foreach(i; 0..N) foreach(j; 0..M) ans[i][j] = '.';

    if (A>0) ans[$-3][$-3] = '<';
    if (A>0) ans[$-3][$-2] = '>';
    if (A>0) A--;
    if (A>0) ans[$-1][$-2] = '<';
    if (A>0) ans[$-1][$-1] = '>';
    if (A>0) A--;
    if (B>0) ans[$-3][$-1] = '^';
    if (B>0) ans[$-2][$-1] = 'v';
    if (B>0) B--;
    if (B>0) ans[$-2][$-3] = '^';
    if (B>0) ans[$-1][$-3] = 'v';
    if (B>0) B--;

    foreach(j; 0..M/2-1) {
        if (A == 0) break;
        ans[$-1][2*j+0] = '<';
        ans[$-1][2*j+1] = '>';
        A--;
    }
    foreach(i; 0..N/2-1) {
        if (B == 0) break;
        ans[2*i+0][$-1] = '^';
        ans[2*i+1][$-1] = 'v';
        B--;
    }
    foreach(i; 0..(N/2)*(M/2)-1) {
        int y = i/(M/2)*2;
        int x = i%(M/2)*2;
        if (A>0) {
            if (A>0) ans[y+0][x+0] = '<';
            if (A>0) ans[y+0][x+1] = '>';
            if (A>0) A--;
            if (A>0) ans[y+1][x+0] = '<';
            if (A>0) ans[y+1][x+1] = '>';
            if (A>0) A--;
        } else if (B>0) {
            if (B>0) ans[y+0][x+0] = '^';
            if (B>0) ans[y+1][x+0] = 'v';
            if (B>0) B--;
            if (B>0) ans[y+0][x+1] = '^';
            if (B>0) ans[y+1][x+1] = 'v';
            if (B>0) B--;
        }
    }
    if (A==0 && B==0) {
        "YES".writeln;
        ans.each!writeln;
        return true;
    }
    return false;
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
