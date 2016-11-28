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

int INF = 1<<25;
bool solve() {
    int H, W;
    readf("%d %d\n", &H, &W);
    if (H==0 && W==0) return false;

    bool[][] flag = H.iota.map!(_ => readln.chomp.map!(c=>c=='.').array).array;
    int[][] ary = new int[][](H, W+1);
    foreach(j; 0..W) {
        int s = 0;
        foreach_reverse(i; 0..H) {
            if (flag[i][j]) {
                ary[i][j] = ++s;
            } else {
                s = 0;
            }
        }
    }

    int ans = 0;
    foreach(i; 0..H) {
        auto list = DList!(int[])([[0, -1]]); // Stack
        foreach(j; 0..W+1) {
            int index = j;
            while(list.back[0]>ary[i][j]) {
                index = list.back[1];
                ans = max(ans, (j-list.back[1])*list.back[0]);
                list.removeBack;
            }
            if (list.back[0]<ary[i][j]) {
                list.insertBack([ary[i][j], index]);
            }
        }
    }
    ans.writeln;
    return true;
}

void main() {
    while(solve()){}
}
