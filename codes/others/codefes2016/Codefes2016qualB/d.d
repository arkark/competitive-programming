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
    int N = readln.chomp.to!int;
    long[] ary = N.rep!(() => readln.chomp.to!long);
    auto rbtree = redBlackTree!(true)(ary);

    long ans = 0;
    while(ary.length>0) {
        bool flg = false;
        long m = 1;
        foreach(a; rbtree) {
            if (a==m) m++;
        }
        foreach(i, ref e; ary) {
            if (e>m) {
                rbtree.removeKey(e);
                ans += (e-1)/m;
                e = (e-1)%m + 1;
                rbtree.insert(e);
                flg = true;
            }
            if (e==m) break;
        }
        int a = ary.length;
        if (!flg) {
            
        }
        ary.writeln;
        if (!flg && ary.length==a) break;
    }
    ans.writeln;
}
