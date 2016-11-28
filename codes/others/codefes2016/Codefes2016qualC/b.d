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
void times(alias pred)(int n) {
    foreach(i; 0..n) pred();
}
auto rep(alias pred, T = typeof(pred()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

void main() {
    int K, T;
    readf("%d %d\n", &K, &T);
    auto ary = readln.split.to!(long[]).enumerate.array.sort!((a, b) => a.value>b.value).array;
    int ans = 0;
    int pre = -1;
    foreach(i; 0..K) {
        ary.sort!((a, b) => a.value>b.value);
        auto a = ary.find!(a => a.index!=pre && a.value>0).array;
        if (a.length > 0) {
            foreach(j, e; ary) {
                if (e.index!=pre && e.value>0) {
                    ary[j].value -= 1;
                    pre = e.index.to!int;
                    break;
                }
            }
        } else {
            ans++;
            ary.front.value -= 1;
        }
    }
    ans.writeln;
}
