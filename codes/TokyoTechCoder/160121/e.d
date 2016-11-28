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
    int M = readln.chomp.to!int;
    int[] a = readln.split.to!(int[]);
    int[] input = readln.split.to!(int[]);
    int s = input[0]-1;
    int g = input[1]-1;
    int[] N = readln.split.to!(int[]);

    bool[] flg = new bool[M];
    flg[s] = true;
    auto list = DList!(Obj)(Obj(s));

    Obj obj;
    while(!list.empty) {
        Obj o = list.front;
        list.removeFront;
        foreach(e; a) {
            int j = o.now+e;
            if (0<=j && j<M) {
                int k = j+N[j];
                if (0<=k && k<M) {
                    if (!flg[k]) {
                        flg[k] = true;
                        Obj _o = Obj(k, o.ary~[e, 1]);
                        if (k == g) {
                            obj = _o;
                            list.clear;
                            break;
                        }
                        list.insertBack(_o);
                    }
                }
            }
            j = o.now-e;
            if (0<=j && j<M) {
                int k = j+N[j];
                if (0<=k && k<M) {
                    if (!flg[k]) {
                        flg[k] = true;
                        Obj _o = Obj(k, o.ary~[e, -1]);
                        if (k == g) {
                            obj = _o;
                            list.clear;
                            break;
                        }
                        list.insertBack(_o);
                    }
                }
            }
        }
    }
    int i=0;
    while (i < obj.ary.length) {
        int t = a[readln.chomp.to!int-1];
        if (obj.ary[i][0] != t) {
            writeln(0);
        } else {
            writeln(obj.ary[i][1]);
            i++;
        }
    }
}
struct Obj {
    int now;
    int[][] ary;
    this(int now, int[][] ary = []) {
        this.now = now;
        this.ary = ary.dup;
    }
}
