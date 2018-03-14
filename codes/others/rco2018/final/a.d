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
import std.random;
alias Generator = std.concurrency.Generator;

const long INF = long.max/3;
const long MOD = 10L^^9+7;

struct Pos {
    int y, x;
}
struct A {
    Pos s, g;
}

void output(Pos p) {
    writeln(p.y, " ", p.x);
}

bool isWall(bool[][] grid, Pos p) {
    return grid[p.y][p.x];
}

void flip(bool[][] grid, Pos p) {
    if (p.y == -1) return;
    grid[p.y][p.x] = !grid[p.y][p.x];
}

int[] dx = [-1, 0, 1, 0];
int[] dy = [0, -1, 0, 1];

void main() {
    auto rnd = Random(unpredictableSeed);

    int N, K;
    bool[][] grid;
    scanln(N, K);
    grid = new bool[][](N, N);

    A[] as = new A[K];
    foreach(i; 0..K) {
        scanln(as[i].s.y, as[i].s.x, as[i].g.y, as[i].g.x);
    }

    int[][] dist = new int[][](N, N);
    int calc(bool[][] grid, A a) {
        if (grid.isWall(a.s)) return 0;
        if (grid.isWall(a.g)) return 0;
        foreach(i; 0..N) dist[i][] = -1;
        auto list = DList!Pos(a.s);
        dist[a.s.y][a.s.x] = 0;
        while(!list.empty) {
            Pos p = list.front;
            list.removeFront;
            if (p == a.g) break;
            foreach(i; 0..4) {
                Pos q = Pos(p.y+dy[i], p.x+dx[i]);
                if (q.y<0 || q.y>=N) continue;
                if (q.x<0 || q.x>=N) continue;
                if (dist[q.y][q.x] >= 0) continue;
                if (grid.isWall(q)) continue;
                dist[q.y][q.x] = dist[p.y][p.x]+1;
                list.insertBack(q);
            }
        }
        return max(0, dist[a.g.y][a.g.x])^^2;
    }

    int sim(Pos[] ps) {
        int res = 0;
        bool[][] grid = new bool[][](N, N);
        foreach(i; 0..K) {
            grid.flip(ps[i]);
            res += calc(grid, as[i]);
        }
        return res;
    }

    Pos[] f(int dx, bool flag) {
        foreach(i; 0..N) grid[i][] = false;
        auto g = new Generator!Pos({
            int s = 4;
            int d = 3;
            int[] ts = [0, 1, 2, 3, 4, 5];
            foreach(i, t; ts) {
                int _x = N/2 + d*t + dx;
                foreach(_y; 0..N-1) {
                    int y = i%2==0 ? _y : N-_y-1;
                    int u = min(y%s, s-y%s)-1;
                    int x = _x+u;
                    x = max(0, min(N-1, x));
                    yield(flag ? Pos(y, x) : Pos(x, y));
                }
                if (t == 0) continue;
                _x = N/2 - d*t + dx;
                foreach(_y; 0..N-1) {
                    int y = i%2==0 ? _y : N-_y-1;
                    int u = min(y%s, s-y%s)-1;
                    int x = _x+u;
                    yield(flag ? Pos(y, x) : Pos(x, y));
                }
            }
        });

        auto list = DList!Pos(g.array);
        Pos[] res = new Pos[K];

        foreach(i, a; as) {
            if (grid.isWall(a.s) && !grid.isWall(a.g)) {
                Pos p = a.s;
                grid.flip(p);
                res[i] = p;
                list.insertFront(p);
            } else if (!grid.isWall(a.s) && grid.isWall(a.g)) {
                Pos p = a.g;
                grid.flip(p);
                res[i] = p;
                list.insertFront(p);
            } else if (!list.empty) {
                Pos p = list.front;
                list.removeFront;
                if (p==a.s || p==a.g) {
                    res[i] = Pos(-1, -1);
                    list.insertFront(p);
                } else {
                    grid.flip(p);
                    res[i] = p;
                }
            } else {
                res[i] = Pos(-1, -1);
            }
        }
        return res;
    }


    void answer(Pos[] ps) {
        ps.each!output;
    }
    // sim(f()).writeln;

    Pos[][] pss = iota(-4, 4+1).map!(i => [f(i, false), f(i, true)]).array.join.array;

    int maxIndex = -1;
    int maxValue = -1;

    foreach(int i, ps; pss) {
        int value = sim(ps);
        // writeln(i, ", ", value);
        if (value > maxValue) {
            maxIndex = i;
            maxValue = value;
        }
    }

    answer(pss[maxIndex]);
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
