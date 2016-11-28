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

void main() {
    int H, W;
    readf("%d %d\n", &H, &W);

    if (W!=3)return;

    int[][] grid = H.rep!(() => readln.chomp.to!(char[])).transposed.map!(a => a.map!(b => b.to!char-'a'+1).array).array;

    int[] cnt = W.rep!(() => 0);
    foreach(x; 0..W) {
        foreach(y1; 0..H) {
            foreach(y2; y1..H) {
                if (x>0 && grid[x-1][y2] == grid[x][y1]) cnt[x]++;
                if (x<W-1 && grid[x+1][y2] == grid[x][y1]) cnt[x]++;
            }
        }
    }

    long ans = 0;
    int[] h = W.rep!(() => 0);
    while(true) {
        if (h[1]==H || (h[0]==H && h[2]==H)) break;

        if (cnt.all!(a => a==0)) break;

        int index;
        if ((h[0]<H && cnt[0]<cnt[1]) || (h[2]<H && cnt[2]<cnt[1])) {
            if (h[0]==H) {
                index = 2;
            } else if (h[2]==H) {
                index = 0;
            } else {
                index = cnt[0]>cnt[2] ? 0:2;
            }
        } else {
            index = 1;
        }

        if (index>0) cnt[index-1] -= grid[index-1][h[index-1]..$].count!(a => a==grid[index].back);
        if (index<W-1) cnt[index+1] -= grid[index+1][h[index+1]..$].count!(a => a==grid[index].back);
        foreach(j; 0..H) {
            auto y = H-j-1;
            if (y>=h[index]) {
                if (index>0 && grid[index-1][y] == grid[index][y]) {
                    ans++;
                    cnt[index]--;
                }
                if (index<W-1 && grid[index+1][y] == grid[index][y]) {
                    ans++;
                    cnt[index]--;
                }
            }
            if (y>h[index]) {
                grid[index][y] = grid[index][y-1];
            } else if (y==h[index]) {
                grid[index][y] = -1;
                h[index]++;
            }
        }
    }
    ans.writeln;
}
