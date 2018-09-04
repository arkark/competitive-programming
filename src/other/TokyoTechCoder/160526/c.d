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

void main() {
    while(true) {
        int N = readln.chomp.to!int;
        if (N==0) break;

        alias Node = Tuple!(int, "l", int, "u", int, "a", int, "p");
        Node[] data = new Node[N];
        foreach(i; 0..N) {
            readf("%d %d %d %d\n", &data[i].l, &data[i].u, &data[i].a, &data[i].p);
        }
        int[] ary = new int[1000];
        int num = 0;
        data.tee!(x=>x.u--).array.sort!((x, y) {
            if (x.a!=y.a) return x.a>y.a;
            if (x.p!=y.p) return x.p<y.p;
            return x.l<y.l;
        }).each!((x) {
            if ((num<10&&ary[x.u]<3) || (num<20&&ary[x.u]<2) || (num<26&&ary[x.u]<1)) {
                num++;
                ary[x.u]++;
                x.l.writeln;
            }
        });
    }
}
