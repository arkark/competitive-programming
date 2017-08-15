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

struct P{size_t index; int value;}
struct Interval {size_t left, right;} // [left, right)
struct T{P even, odd;}

const P initValue = P(0, int.max);
alias RMQ = SegTree!(
    P, (a, b) => a.value<b.value ? a:b, initValue
);

int N;
P[] ps;
RMQ[] rmqs;

T f(Interval interval) {
    if (interval.left>=interval.right) return T(initValue, initValue);
    assert((interval.right - interval.left)%2 == 0);

    P even = rmqs[(interval.left + 0)%2].query(interval.left, interval.right);
    P odd  = rmqs[(interval.left + 1)%2].query(   even.index, interval.right);
    return T(even, odd);
}

void main() {
    N = readln.chomp.to!int;
    ps = readln.split.to!(int[]).enumerate.map!(a => P(a.index, a.value)).array;
    rmqs = [
        RMQ(ps.map!(p => p.index%2==0 ? p : initValue.to!P).array), // even
        RMQ(ps.map!(p => p.index%2==0 ? initValue.to!P : p).array)  // odd
    ];

    auto tree = redBlackTree!(
        (Interval a, Interval b) => memoize!f(a).even.value < memoize!f(b).even.value,
        false,
        Interval
    )(Interval(0, N));

    auto ans = DList!P();
    while(!tree.empty) {
        Interval interval = tree.front;
        tree.removeFront;
        if (interval.left>=interval.right) continue;

        T t = memoize!f(interval);
        ans.insertBack(t.even);
        ans.insertBack(t.odd);

        tree.insert(Interval(interval.left, t.even.index));
        tree.insert(Interval(t.even.index + 1, t.odd.index));
        tree.insert(Interval(t.odd.index + 1, interval.right));
    }

    ans[].map!"a.value".map!(to!string).join(" ").writeln;
}



// SegTree (Segment Tree)
struct SegTree(T, alias fun, T initValue)
    if (is(typeof(fun(T.init, T.init)) : T)) {

private:
    T[] _data;
    size_t _size;
    size_t _l, _r;

public:
    // size ... データ数
    // initValue ... 初期値(例えばRMQだとINF)
    this(size_t size) {
        init(size);
    }

    // 配列で指定
    this(T[] ary) {
        init(ary.length);
        update(ary);
    }

    // O(N)
    void init(size_t size){
        _size = 1;
        while(_size < size) {
            _size *= 2;
        }
        _data.length = _size*2-1;
        _data[] = initValue;
        _l = 0;
        _r = size;
    }

    // i番目の要素をxに変更
    // O(logN)
    void update(size_t i, T x) {
        i += _size-1;
        _data[i] = x;
        while(i>0) {
            i = (i-1)/2;
            _data[i] = fun(_data[i*2+1], _data[i*2+2]);
        }
    }

    // 配列で指定
    // O(N)
    void update(T[] ary) {
        foreach(size_t i, e; ary) {
            size_t _i = i+_size-1;
            _data[_i] = e;
        }
        foreach(i; 0.._size-1) {
            size_t _i = _size-i-2;
            _data[_i] = fun(_data[_i*2+1], _data[_i*2+2]);
        }
    }

    // 区間[a, b)でのクエリ
    // O(logN)
    T query(size_t a, size_t b) {
        T rec(size_t a, size_t b, size_t k, size_t l, size_t r) {
            if (b<=l || r<=a) return initValue;
            if (a<=l && r<=b) return _data[k];
            T vl = rec(a, b, k*2+1, l, (l+r)/2);
            T vr = rec(a, b, k*2+2, (l+r)/2, r);
            return fun(vl, vr);
        }
        return rec(a, b, 0, 0, _size);
    }

    // O(N)
    T[] array() {
        return _data[_l+_size-1.._r+_size-1];
    }
}


// ----------------------------------------------

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
