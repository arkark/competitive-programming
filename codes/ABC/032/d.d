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
    int[] input = readln.split.to!(int[]);
    int N = input[0];
    int W = input[1];
    int[] v = new int[N];
    int[] w = new int[N];
    foreach(i; 0..N) {
        input = readln.split.to!(int[]);
        v[i] = input[0];
        w[i] = input[1];
    }
    if (w.count!(a=> a>1000) == 0) {
        long[] ary = new long[1000*200];
        ary[1..$] = -1;
        foreach(i; 0..N) {
            long[] _ary = ary.dup;
            foreach(j, e; _ary) {
                if (e<0) continue;
                if (j+w[i]<=W) {
                    ary[j+w[i]] = max(ary[j+w[i]], e+v[i]);
                }
            }
        }
        ary.reduce!max.writeln;
    } else if (v.count!(a=> a>1000) == 0) {
        long INF = 1L<<60;
        int M = 1000*200;
        long[][] ary = new long[][](N+1, M+1);
        foreach(i, ref e; ary) e[] = INF;
        ary[0][0] = 0;
        foreach(i; 0..N) {
            foreach(j; 0..M+1) {
                if (j-v[i] < 0) {
                    ary[i+1][j] = ary[i][j];
                } else {
                    ary[i+1][j] = min(ary[i][j], ary[i][j-v[i]]+w[i]);
                }
            }
        }
        foreach_reverse(i, e; ary[N]) {
            if (e<=W) {
                i.writeln;
                break;
            }
        }
    } else {
        long[int] aa;
        aa[0] = 0;
        foreach(i; 0..N) {
            long[int] _aa = aa.dup;
            foreach(k, value; _aa) {
                if (k+w[i]<=W) {
                    aa[k+w[i]] = max((k+w[i] in aa) ? aa[k+w[i]]:0, value+v[i]);
                }
            }
        }
        aa.reduce!max.writeln;
    }

}
