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

void main() {
    int R, C, K;
    readf("%d %d %d\n", &R, &C, &K);
    bool[][] flag = R.iota.map!(_ => readln.chomp.map!(c => c=='o').array).array;
    int[][][] grid = new int[][][](R, C, 2);
    foreach(i; 0..R) {
        int s = 0;
        foreach(j; 0..C) {
            s = flag[i][j] ? s+1:0;
            grid[i][j][0] = s;
        }
        s = 0;
        foreach_reverse(j; 0..C) {
            s = flag[i][j] ? s+1:0;
            grid[i][j][1] = s;
        }
    }
    int ans = 0;
    foreach(i; K-1..R-K+1) foreach(j; K-1..C-K+1) {
        if ((x, y){
            foreach(k; 0..K) {
                if (grid[x-k][y][0]<K-k || grid[x-k][y][1]<K-k || grid[x+k][y][0]<K-k || grid[x+k][y][1]<K-k) return false;
            }
            return true;
        }(i, j)) ans++;
    }
    ans.writeln;
}
