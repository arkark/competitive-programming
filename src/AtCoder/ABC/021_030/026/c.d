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
void times(alias fun)(int n) {
    foreach(i; 0..n) fun();
}
auto rep(alias fun, T = typeof(fun()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = fun();
    return res;
}
// fold was added in D 2.071.0.
template fold(fun...) if (fun.length >= 1) {
    auto fold(R, S...)(R r, S seed) {
        static if (S.length < 2) {
            return reduce!fun(seed, r);
        } else {
            return reduce!fun(tuple(seed), r);
        }
    }
}

immutable INF = int.max/3;
class Person{
    int boss;
    int minV=INF, maxV=-INF;
    int value() {
        return minV>maxV ? 1 : minV+maxV+1;
    }
    this(int boss) {
        this.boss = boss;
    }
}
void main() {
    int N = readln.chomp.to!int;
    Person[] ary = new Person(0) ~ (N-1).rep!(() => new Person(readln.chomp.to!int-1));
    auto tree = redBlackTree!((a, b) => a.boss>b.boss, true)(ary.drop(1));
    foreach(p; tree) {
        ary[p.boss].minV = min(ary[p.boss].minV, p.value);
        ary[p.boss].maxV = max(ary[p.boss].maxV, p.value);
    }
    ary.front.value.writeln;
}
