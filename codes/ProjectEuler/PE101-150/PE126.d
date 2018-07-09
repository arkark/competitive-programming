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
    const int MAX = 20000;
    int[] ary = new int[MAX+1];
    int ans = 0;
    foreach(a; 1..MAX) {
        if (calc(a,a,a,1)>MAX) break;
        foreach(b; a..MAX) {
            if (calc(a,b,b,1)>MAX) break;
            foreach(c; b..MAX) {
                for(int n=1; ; n++) {
                    int temp = calc(a, b, c, n);
                    if (temp > MAX) break;
                    ary[temp]++;
                }
            }
        }
    }
    foreach(i, a; ary) {
        if (a==1000) {
            writeln(i);
            break;
        }
    }
}

int calc(int a, int b, int c, int n) {
    return 2*(a*b + b*c + c*a) + 4*(n-1)*(a+b+c) + 4*(n-1)*(n-2);
}
