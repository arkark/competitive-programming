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

ModNum[][] dp;

void main() {
    int N, M;
    scanln(N, M);
    int[] as = readln.split.to!(int[]);
    int[] bs = readln.split.to!(int[]);

    dp = new ModNum[][](101, 1001); // 分割数
    dp[0][0] = 1;
    foreach(i; 1..100+1) {
        foreach(j; 0..1000+1) {
            if (j-i>=0) {
                dp[i][j] = dp[i-1][j] + dp[i][j-i];
            } else {
                dp[i][j] = dp[i-1][j];
            }
        }
    }

    writeln(solve(as, bs) * solve(bs, as));
}

ModNum solve(int[] as, int[] bs) {
    int[] cs = bs.group.map!"a[1]".map!(to!int).array.sort!"a<b".array;
    int K = cs.length.to!int;
    int S = as.sum;
    ModNum[][] dp2 = new ModNum[][](K+1, S+1);
    foreach(j; 0..S+1) {
        dp2[0][j] = dp[0][j];
    }
    foreach(i; 1..K+1) {
        foreach(j; 0..S+1) {
            foreach(k; 0..j+1) {
                dp2[i][j] += dp2[i-1][j-k] * dp[cs[i-1]][k];
            }
        }
    }
    return dp2[K][S];
}

alias ModNum = ModNumber!(long, MOD);

struct ModNumber(T, T mod) if (__traits(isIntegral, T)) {
    T value;
    this(S: T)(S value) {
        this.value = value;
    }
    typeof(this) opAssign(S: T)(S value) {
        this.value = value;
        return this;
    }
    typeof(this) opBinary(string op)(typeof(this) that) if (op=="+" || op=="-" || op=="*") {
        mixin("return typeof(this)((this.value"~op~"that.value+mod)%mod);");
    }
    typeof(this) opBinary(string op)(typeof(this) that) if (op == "/") {
        return this*getReciprocal(that);
    }
    typeof(this) opBinary(string op)(typeof(this) that) if (op == "^^") {
        return typeof(this)(modPow(this.value, that.value));
    }
    typeof(this) opBinary(string op, S)(S that) if (op == "^^" && __traits(isIntegral, S)) {
        return typeof(this)(modPow(this.value, that));
    }
    void opOpAssign(string op)(typeof(this) that) if (op=="+" || op=="-" || op=="*" || op=="/") {
        mixin("this = this" ~op~ "that;");
    }
    typeof(this) getReciprocal(typeof(this) x) in {
        debug {
            assert(isPrime(mod));
        }
    } body {
        return typeof(this)(modPow(x.value, mod-2));
    }
    T modPow(T base, T power)  {
        T result = 1;
        for (; power > 0; power >>= 1) {
            if (power & 1) {
                result = (result * base) % mod;
            }
            base = base^^2 % mod;
        }
        return result;
    }
    string toString() {
        import std.conv;
        return this.value.to!string;
    }
    invariant() {
        assert(this.value>=0);
        assert(this.value<mod);
    }
    bool isPrime(T n) {
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
