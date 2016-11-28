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

int[] dx = [1,0,-1,0];
int[] dy = [0,1,0,-1];
struct Pos{size_t y, x;}
long MOD = 10^^9+7;
void main() {
    int[] input = readln.split.to!(int[]);
    int H = input[0];
    int W = input[1];
    int[][] grid = H.iota.map!(_=>readln.split.to!(int[])).array;

    long[][] dp = H.iota.map!(_=>1L.repeat(W).array).array;
    grid.join.enumerate.map!(e => Pos(e[0]/W, e[0]%W)).array.sort!((a, b) => grid[a.y][a.x]>grid[b.y][b.x]).each!(p =>
        dp[p.y][p.x] = reduce!((x, y) => (x+y)%MOD)(
            dp[p.y][p.x],
            4.iota.map!(i => Pos(p.y+dy[i], p.x+dx[i])).filter!(_p =>
                0<=_p.y && _p.y<H && 0<=_p.x && _p.x<W && grid[p.y][p.x]<grid[_p.y][_p.x]
            ).map!(_p => dp[_p.y][_p.x])
        )
    );

    reduce!((a, b) => (a+b)%MOD)(0L, dp.join).writeln;
}
