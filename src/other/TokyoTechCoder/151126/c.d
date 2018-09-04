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
    string[] input = readln.split;
    int N = input[0].to!int;
    int T = input[1].to!int;
    int H = input[2].to!int;
    int L = input[3].to!int;
    int[] t = new int[N];
    int[] h = new int[N];
    foreach(int i; 0..N) {
        input = readln.split;
        t[i] = input[0].to!int;
        h[i] = input[1].to!int;
    }

    int i=-1;
    int x = 0; // 残金
    while(true) {
        i = (i+1)%N;
        if (t[i] > 0) {
            t[i]--; T++; x+=10;
        } else if (h[i] > 0) {
            h[i]--; H++; x+=100;
        } else {
            break;
        }
        if (T > L) break;
        if (x >= 90) {
            bool flg = false;
            for (int j = T; j>=0; j--) {
                if (x-90-10*j>=0 && (x-90-10*j)%100==0 && (x-90-10*j)/100<=H) {
                    x=0;
                    T-=j; H-=(x-90-10*j)/100;
                    t[i]+=j; h[i]+=(x-90-10*j)/100;
                    flg = true;
                    break;
                }
            }
            if (!flg) break;
        }
    }
    writeln(i+1);
}
