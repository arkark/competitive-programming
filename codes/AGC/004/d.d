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
    int N, K;
    readf("%d %d\n", &N, &K);
    int[] ary = readln.split.to!(int[]).map!"a-1".array;

    int[][] edges = new int[][N];
    ary.enumerate.drop(1).each!(a => edges[a.value] ~= a.index.to!int);

    int[] dist = new int[N];
    dist.front = 0;
    N.rep!(()=>false).pipe!((flg) {
        flg.front = true;
        auto list = DList!int(0);
        while(!list.empty) {
            int i = list.front;
            list.removeFront;
            edges[i].each!((j) {
                if (!flg[j]) {
                    list.insertBack(j);
                    flg[j] = true;
                    dist[j] = dist[i]+1;
                }
            });
        }
    });

    ((ary.front!=0 ? 1:0) + dist.drop(1).count!(a => a>1 && (a-1)%K==0)).writeln;
}
