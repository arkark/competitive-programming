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

void main() {
    int n = readln.chomp.to!int;
    auto deque = Deque!long();
    long[] as = readln.split.to!(long[]);
    foreach(i, a; as) {
        if (i%2==0) {
            deque.insertBack(a);
        } else {
            deque.insertFront(a);
        }
    }
    (n%2==0 ? array(deque) : array(retro(deque))).map!(to!string).join(" ").writeln;
}

// Deque - implemented in dynamic arrays

struct Deque(T) {
    import std.range, std.algorithm, std.conv, std.format;

private:
    T[] frontData = [];
    T[] backData = [];

    // [frontIndex, backIndex)
    int frontIndex = 0;
    int backIndex = 0;

public:

    this(T[] data) {
        this([], data, 0, cast(int)data.length, false);
    }

    bool empty() @property {
        return frontIndex == backIndex;
    }

    size_t length() @property {
        return cast(size_t) (backIndex - frontIndex);
    }

    void clear() {
        frontIndex = backIndex = 0;
        frontData = [];
        backData = [];
    }

    ref T front() @property in {
        assert(!empty, "Attempting to get the front of an empty Deque");
    } body {
        return this[0];
    }

    ref T front(T value) @property in {
        assert(!empty, "Attempting to assign to the front of an empty Deque");
    } body {
        return this[0] = value;
    }

    ref T back() @property in {
        assert(!empty, "Attempting to get the back of an empty Deque");
    } body {
        return this[$-1];
    }

    ref T back(T value) @property in {
        assert(!empty, "Attempting to assign to the back of an empty Deque");
    } body {
        return this[$-1] = value;
    }

    void insertFront(T value) {
        if (frontIndex>0) {
            backData[frontIndex - 1] = value;
        } else {
            frontData ~= value;
        }
        frontIndex--;
    }

    void insertBack(T value) {
        if (backIndex < 0) {
            frontData[-backIndex - 1] = value;
        } else {
            backData ~= value;
        }
        backIndex++;
    }

    void removeFront() in {
        assert(!empty, "Attempting to remove the front of an empty Deque");
    } body {
        if (frontIndex >= 0) {
            // do nothing
        } else {
            frontData = frontData[0..$-1];
        }
        frontIndex++;
    }
    alias popFront = removeFront;

    void removeBack() in {
        assert(!empty, "Attempting to remove the back of an empty Deque");
    } body {
        if (backIndex <= 0) {
            // do nothing
        } else {
            backData = backData[0..$-1];
        }
        backIndex--;
    }
    alias popBack = removeBack;

    typeof(this) save() @property {
        return typeof(this)(frontData, backData, frontIndex, backIndex, true);
    }

    void reserveFront(int num) {
        frontData.reserve(num);
    }

    void reserveBack(int num) {
        backData.reserve(num);
    }

    // xs ~= value
    typeof(this) opOpAssign(string op)(T value) if (op == "~") {
        this.insertBack(value);
        return this;
    }

    // xs[index]
    ref T opIndex(size_t index) in {
        assert(0<=index && index<length, "Access violation");
    } body {
        int _index = frontIndex + (cast(int)index);
        return _index>=0 ? backData[_index] : frontData[-_index - 1];
    }

    // xs[indices[0] .. indices[1]]
    typeof(this) opIndex(size_t[2] indices) in {
        assert(0<=indices[0] && indices[1]<=length, "Access violation");
    } body {
        return typeof(this)(frontData, backData, frontIndex + cast(int)indices[0], frontIndex + cast(int)indices[1], false);
    }

    // xs[]
    typeof(this) opIndex() {
        return this;
    }

    // xs[index] = value
    ref T opIndexAssign(T value, size_t index) in {
        assert(0<=index && index<length, "Access violation");
    } body {
        int _index = (cast(int)index) - frontIndex;
        return (_index>=0 ? backData[_index] : frontData[-_index - 1]) = value;
    }

    // xs[indices[0] .. indices[1]] = value
    typeof(this) opIndexAssign(T value, size_t[2] indices) in {
        assert(0<=indices[0] && indices[1]<=length, "Access violation");
    } body {
        int _frontIndex = frontIndex + (cast(int) indices[0]);
        int _backIndex = frontIndex + (cast(int) indices[1]);
        frontData[clamp(-_backIndex, 0, $)..clamp(-_frontIndex, 0, $)] = value;
        backData[clamp(_frontIndex, 0, $)..clamp(_backIndex, 0, $)] = value;
        return this;
    }

    // xs[] = value
    typeof(this) opIndexAssign(T value) {
        backData[] = value;
        frontData[] = value;
        return this;
    }

    // xs[indices[0] .. indices[1]] op= value
    typeof(this) opIndexOpAssign(string op)(T value, size_t[2] indices) in {
        assert(0<=indices[0] && indices[1]<=length, "Access violation");
    } body {
        int _frontIndex = frontIndex + (cast(int) indices[0]);
        int _backIndex = frontIndex + (cast(int) indices[1]);
        mixin(
            "frontData[clamp(-_backIndex, 0, $)..clamp(-_frontIndex, 0, $)] %s= value;".format(op)
        );
        mixin(
            "backData[clamp(_frontIndex, 0, $)..clamp(_backIndex, 0, $)] %s= value;".format(op)
        );
        return this;
    }

    // xs[] op= value
    typeof(this) opIndexOpAssign(string op)(T value) {
        mixin(
            "frontData[] %s= value;".format(op)
        );
        mixin(
            "backData[] %s= value;".format(op)
        );
        return this;
    }

    // $
    size_t opDollar(size_t dim: 0)() {
        return length;
    }

    // i..j
    size_t[2] opSlice(size_t dim: 0)(size_t i, size_t j) in {
        assert(0<=i && j<=length, "Access violation");
    } body {
        return [i, j];
    }

    bool opEquals(S: T)(Deque!S that) {
        if (this.length != that.length) return false;
        foreach(i; 0..this.length) {
            if (this[i] != that[i]) return false;
        }
        return true;
    }

    bool opEquals(S: T)(S[] that) {
        if (this.length != that.length) return false;
        foreach(i; 0..this.length) {
            if (this[i] != that[i]) return false;
        }
        return true;
    }

    string toString() const {
        auto xs = frontData[clamp(-backIndex, 0, $)..clamp(-frontIndex, 0, $)];
        auto ys = backData[clamp(frontIndex, 0, $)..clamp(backIndex, 0, $)];
        return "Deque(%s)".format(xs.retro.array ~ ys);
    }

private:
    this(T[] frontData, T[] backData, int frontIndex, int backIndex, bool duplicated) {
        this.frontData = duplicated ? frontData.dup : frontData[0..clamp(-frontIndex, 0, $)];
        this.backData = duplicated ? backData.dup : backData[0..clamp(backIndex, 0, $)];
        this.frontIndex = frontIndex;
        this.backIndex = backIndex;
    }

    invariant {
        assert(-frontIndex <= cast(int)frontData.length);
        assert(frontIndex <= backIndex);
        assert(backIndex <= cast(int)backData.length);
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
