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

long[][] bAry;
long[][] cAry;
void main() {
    bAry = 2.rep!(() => readln.split.to!(long[]));
    cAry = 3.rep!(() => readln.split.to!(long[]));
    long t = rec(0, -INF, INF, new int[][](3, 3));
    long s = bAry.map!sum.sum + cAry.map!sum.sum;
    writeln((s+t)/2);
    writeln((s-t)/2);
}

long INF = long.max/3;
long rec(int depth, long mini, long maxi, int[][] board) {
    if (depth == 9) {
        long res = 0;
        foreach(i; 0..3) foreach(j; 0..3) {
            if (i<2) res += bAry[i][j] * (board[i][j]==board[i+1][j] ? 1:-1);
            if (j<2) res += cAry[i][j] * (board[i][j]==board[i][j+1] ? 1:-1);
        }
        return res;
    } else if (depth%2==0) {
        auto res = -INF;
        foreach(i; 0..3) foreach(j; 0..3) {
            if (board[i][j] == 0) {
                board[i][j] = 1;
                res = max(res, rec(depth+1, mini, maxi, board));
                board[i][j] = 0;
                if (res > maxi) return res;
            }
            mini = max(mini, res);
        }
        return res;
    } else {
        long res = INF;
        foreach(i; 0..3) foreach(j; 0..3) {
            if (board[i][j] == 0) {
                board[i][j] = -1;
                res = min(res, rec(depth+1, mini, maxi, board));
                board[i][j] = 0;
                if (res < mini) return res;
            }
            maxi = min(maxi, res);
        }
        return res;
    }
}
