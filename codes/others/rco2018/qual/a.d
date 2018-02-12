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

import std.random;

const long INF = long.max/3;
const long MOD = 10L^^9+7;

int N, K, H, W, T;
Board[] boards;
int[] dy = [0, -1, 0, 1];
int[] dx = [-1, 0, 1, 0];
void main() {
    auto rnd = Random(unpredictableSeed);
    with(Type) {
        scanln(N, K, H, W, T);

        boards.length = N;
        foreach(i; 0..N) {
            boards[i].grid = new Type[][](H, W);
            foreach(y; 0..H) {
                Type[] row = readln.chomp.map!(
                    a => a=='o' ? Coin
                       : a=='x' ? Trap
                       : a=='#' ? Wall
                       : None
                ).array;
                foreach(x; 0..W) {
                    boards[i].grid[y][x] = row[x];
                    if (row[x] == None) {
                        boards[i].initPos = Pos(y, x);
                    }
                }
            }
        }

        int[] getCommand(Board _board) {
            Board board = _board.clone;

            int maxNum = -1;
            int[] maxCommand;

            int[][] memo = new int[][](H, W);
            foreach(y; 0..H) memo[y][] = -1;

            static int aaaaaa = 0;

            void rec(int depth, Board _b, Pos p, int[] command, int num, int branchNum) {
                if (aaaaaa++ > 200000) return;

                if (num > maxNum) {
                    maxNum = num;
                    maxCommand = command[0..depth].dup;
                }
                if (depth >= T) return;

                if (branchNum > min(4, depth*10/T + 2)) return; //
                branchNum--;

                Board b = _b.clone;
                if (b.getType(p) == Coin) {
                    num++;
                } else {
                    if (memo[p.y][p.x] >= num) {
                        return;
                    }
                }
                memo[p.y][p.x] = num;
                b.setType(p, None);

                bool flag = false;
                int[] es = 4.iota.array;
                randomShuffle(es, rnd);
                foreach(i; es) {
                    Pos q = Pos(p.y+dy[i], p.x+dx[i]);
                    if (b.getType(q) == Coin) {
                        branchNum++;
                        command[depth] = i;
                        rec(depth + 1, b, q, command, num, branchNum);
                        flag = true;
                    }
                }
                if (!flag) {
                    foreach(i; es) {
                        Pos q = Pos(p.y+dy[i], p.x+dx[i]);
                        if (b.getType(q) == None) {
                            branchNum++;
                            command[depth] = i;
                            rec(depth + 1, b, q, command, num, branchNum);
                            flag = true;
                        }
                    }
                }
            }

            rec(0, board, board.initPos, new int[T], 0, 1);
            return maxCommand;
        }


        string getCommandString(int[] command) {
            return command.map!(
                a => a==0 ? "L" : a==1 ? "U" : a==2 ? "R" : "D"
            ).array.join;
        }
        int[][] maxCommands = boards.map!(b =>  getCommand(b)).array;

        int[] appendRandomCommand(int[] _command) {
            int[] command = _command.dup;
            import std.random;
            auto rnd = Random(unpredictableSeed);
            int k = command.length.to!int;
            command.length = T;
            foreach(i; k..T) {
                command[i] = uniform(0, 4, rnd);
            }
            return command;
        }

        maxCommands = maxCommands.map!(c => 15.rep!(() => appendRandomCommand(c))).join.array;

        int getScore(Board _board, int[] command) {
            Board board = _board.clone;

            int res = 0;
            Pos p = board.initPos;
            foreach(i; command) {
                Pos q = Pos(p.y+dy[i], p.x+dx[i]);
                Type t = board.getType(q);
                if (t == None) {
                    p = q;
                } else if (t == Coin) {
                    res++;
                    board.setType(q, None);
                    p = q;
                } else if (t == Trap) {
                    break;
                } else if (t == Wall) {
                    // do nothing
                } else {
                    assert(false);
                }
            }

            return res;
        }

        long maxValue = 0;
        int[] maxMs;
        int[] maxCommand;
        foreach(command; maxCommands) {
            auto po = boards.map!(b => getScore(b, command)).enumerate.array.sort!"a.value>b.value".take(K).array;
            long value = po.map!"a.value".sum;
            if (value > maxValue) {
                maxValue = value;
                maxMs = po.map!"a.index".map!(to!int).array;
                maxCommand = command;
            }
        }

        maxMs.map!(to!string).join(" ").writeln;
        getCommandString(maxCommand).writeln;
    }
}

struct Pos {
    int y, x;
}

enum  Type {
    None,
    Coin,
    Trap,
    Wall
}

struct Board {
    Pos initPos;
    Type[][] grid;

    Type getType(Pos p) {
        return grid[p.y][p.x];
    }
    void setType(Pos p, Type t) {
        grid[p.y][p.x] = t;
    }

    Board clone() {
        return Board(initPos, grid.map!(row => row.dup).array);
    }

    string toString() {
        string res;
        foreach(y; 0..H) {
            if (y>0) res ~= "\n";
            foreach(x; 0..W) {
                with(Type) {
                    if (initPos == Pos(y, x)) {
                        res ~= "@";
                    } else {
                        res ~= grid[y][x].pipe!(
                            a => a==None ? "_"
                               : a==Coin ? "o"
                               : a==Trap ? "x"
                               : a==Wall ? "#"
                               : "?"
                        );
                    }
                }
            }
        }
        return res;
    }
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
