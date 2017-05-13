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
void times(alias fun)(int n) {
    foreach(i; 0..n) fun();
}
auto rep(alias fun, T = typeof(fun()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = fun();
    return res;
}
// fold was added in D 2.071.0.
template fold(fun...) if (fun.length >= 1) {
    auto fold(R, S...)(R r, S seed) {
        static if (S.length < 2) {
            return reduce!fun(seed, r);
        } else {
            return reduce!fun(tuple(seed), r);
        }
    }
}

void main() {
    int W, H, N;
    readf("%d %d %d\n", &W, &H, &N);
    int[][] grid = new int[][](W+1, H+1);
    N.times!({
        int x, y, a;
        readf("%d %d %d\n", &x, &y, &a);
        a==1 ? {
            grid[0][0]++;
            grid[x][0]--;
            grid[0][H]--;
            grid[x][H]++;
        }() : a==2 ? {
            grid[x][0]++;
            grid[W][0]--;
            grid[x][H]--;
            grid[W][H]++;
        }() : a==3 ? {
            grid[0][0]++;
            grid[W][0]--;
            grid[0][y]--;
            grid[W][y]++;
        }() : {
            grid[0][y]++;
            grid[W][y]--;
            grid[0][H]--;
            grid[W][H]++;
        }();
    });
    foreach(i; 0..W) foreach(j; 1..H) {
        grid[i][j] += grid[i][j-1];
    }
    foreach(i; 1..W) foreach(j; 0..H) {
        grid[i][j] += grid[i-1][j];
    }
    grid[0..$-1].map!"a[0..$-1]".join.count!"a==0".writeln;
}
