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
    auto as = readln.split.to!(long[]).group.array;
    ModNum ans = 1;
    foreach(i; 0..as.length) {
        if (as[i][0] >= 0) continue;
        ans *= ModNum.hComb(as[i+1][0]-as[i-1][0]+1, as[i][1]);
    }
    ans.writeln;
}

alias ModNum = ModNumber!(long, MOD);

struct ModNumber(T, T mod) if (__traits(isIntegral, T)) {
    private enum FACT_MAX = 1000000;

    T value;
    this(T value) {
        this.value = value;
        this.value %= MOD;
        this.value += MOD;
        this.value %= MOD;
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

    static bool isPrime(T n) {
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

    // n! : 階乗
    static ModNumber fact(T n) {
        assert(0<=n && n<=FACT_MAX);
        static ModNumber[] memo;
        if (memo.length == 0) memo = new ModNumber[FACT_MAX+1];
        if (memo[n] != ModNumber.init) {
            return memo[n];
        } else {
            return memo[n] = n==0 ? ModNumber(1) : n*fact(n-1);
        }
    }

    // 1/(n!) : 階乗の逆元 (逆元テーブルを用いる)
    static ModNumber invFact(T n) {
        assert(0<=n && n<=FACT_MAX);
        static ModNumber inverse(T n) {
            assert(1<=n && n<=FACT_MAX);
            static ModNumber[] memo;
            if (memo.length == 0) memo = new ModNumber[FACT_MAX+1];
            if (memo[n] != ModNumber.init) {
                return memo[n];
            } else {
                return memo[n] = n==1 ? ModNumber(1) : ModNumber(-MOD/n)*inverse(MOD%n);
            }
        }
        static ModNumber[] memo;
        if (memo.length == 0) memo = new ModNumber[FACT_MAX+1];
        if (memo[n] != ModNumber.init) {
            return memo[n];
        } else {
            return memo[n] = n==0 ? ModNumber(1) : inverse(n)*invFact(n-1);
        }
    }

    // {}_n C_r: 組合せ
    static ModNumber comb(T n, T r) {
        import std.functional : memoize;
        if (r<0 || r>n) return ModNumber(0);
        if (r*2 > n) return comb(n, n-r);

        if (n<=FACT_MAX) {
            return fact(n) * invFact(r) * invFact(n-r); // 逆元テーブルを使用する
            // return fact(n) / fact(r) / fact(n-r); // 逆元テーブルを使用しない
        }

        ModNum mul(T l, T r) {
            return l>r ? ModNumber(1) : l * memoize!mul(l+1, r);
        }
        return memoize!mul(n-r+1, n) / memoize!mul(1, r);
    }

    // {}_n H_r: 重複組合せ (Homogeneous Combination)
    static ModNumber hComb(T n, T r) {
        return comb(n+r-1, r);
    }

    string toString() {
        import std.conv;
        return this.value.to!string;
    }

    invariant {
        assert(this.value>=0);
        assert(this.value<mod);
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
