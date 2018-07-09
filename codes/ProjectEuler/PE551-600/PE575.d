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

int N = 5;
int maxDepth = 10000;
double[][] grid, _grid;
void main() {
    grid  = new double[][](N, N);
    _grid = new double[][](N, N);
    foreach(x; 0..N) foreach(y; 0..N) {
        grid[x][y] = 1.0/(N*N);
    }

    foreach(i; 0..maxDepth) {
        if (i%1000==0)i.writeln;
        po();
    }

grid.writeln;
writefln("%.12f", grid.map!(a => a.sum).sum);
    writefln("%.12f", N.iota.map!"a+1".map!(i => i*i-1).map!(i => grid[i%N][i/N]).sum);
}

int[] dx = [0, -1, 0, 0, 1];
int[] dy = [0, 0, -1, 1, 0];
void po() {
    foreach(x; 0..N) foreach(y; 0..N) {
        _grid[x][y] = grid[x][y];
        grid[x][y] = 0.0;
    }
    foreach(x; 0..N) foreach(y; 0..N) {
        int cnt = 5.iota.count!(i => isInner(x+dx[i], y+dy[i]));
        double r = _grid[x][y];
        double r1 = r / cnt / 2.0;
        double r2 = r / (cnt-1) / 4.0;
        double r3 = r / 4.0;
        5.iota.filter!(i => isInner(x+dx[i], y+dy[i])).each!((i){
            grid[x+dx[i]][y+dy[i]] += r1;
            grid[x+dx[i]][y+dy[i]] += i==0 ? r3:r2;
        });
    }
}
bool isInner(int x, int y) {
    return 0<=x && x<N && 0<=y && y<N;
}
