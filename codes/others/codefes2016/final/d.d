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
    int N, M;
    readf("%d %d\n", &N, &M);

    (new int[][M]).pipe!((a) {
      readln.split.to!(int[]).each!((x) {
          a[x%M] ~= x;
      });
      return a;
    }).map!(a =>
        redBlackTree!((b, c) =>
            (b[1]+c[1])%2!=0 ? b[1]%2!=0 :
            b[1] != c[1]     ? b[1]>c[1] :
                               b[0]<c[0]
        )(a.sort().group.array ~ tuple!(int, uint)(-1, 0))
    ).array.pipe!((ary) {
        int v1 = (M/2 + 1).iota.map!((i){
            int cnt = 0;
            if (i==0 || i*2==M) {
                cnt = ary[i][].map!(a => a[1]).sum/2;
                ary[i].clear;
            } else {
                int j = M-i;
                while([i, j].all!(k => ary[k].front[1]>0)) {
                    cnt++;
                    [i, j].each!(k =>
                        ary[k].pipe!((tree) {
                            auto v = tree.front;
                            tree.removeFront;
                            v[1]--;
                            tree.insert(v);
                        })
                    );
                }
            }
            return cnt;
        }).array.sum;
        int v2 = ary.map!(a => a[].map!(b => b[1]/2).sum).sum;
        return v1+v2;
    }).writeln;
}
