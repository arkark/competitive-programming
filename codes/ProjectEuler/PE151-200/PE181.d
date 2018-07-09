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
    // 母関数を用いて分割数を求める
    int B = 60;
    int W = 40;
    long[][] ary = new long[][](B+1, W+1);
    ary[0][0] = 1;
    foreach(x; 0..B+1) foreach(y; 0..W+1) {
        if (x==0 && y==0) continue;
        long[][] _ary = ary;
        ary = new long[][](B+1, W+1);
        for(int k=0; k*x<=B && k*y<=W; k++) {
            for(int i=0; i+k*x<=B; i++) {
                for(int j=0; j+k*y<=W; j++) {
                    ary[i+k*x][j+k*y] += _ary[i][j];
                }
            }
        }
    }
    ary.writeln;
    ary.back.back.writeln;
}
