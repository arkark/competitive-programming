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
    int N, M, P, Q, R;
    readf("%d %d %d %d %d\n", &N, &M, &P, &Q, &R);
    int[][] value = new int[][](N, M);
    foreach(i; 0..R) {
        int x, y, z;
        readf("%d %d %d\n", &x, &y, &z);
        value[x-1][y-1] = z;
    }
    int rec(int depth, int[] ary) {
        if (ary.length>P) return 0;
        if (depth==N) {
            if (ary.length<P) return 0;
            return M.iota.map!(m => ary.map!(n => value[n][m]).reduce!"a+b").array.sort!"a>b"[0..Q].reduce!"a+b";
        } else {
            return max(rec(depth+1, ary~depth), rec(depth+1, ary));
        }
    }
    rec(0, []).writeln;
}
