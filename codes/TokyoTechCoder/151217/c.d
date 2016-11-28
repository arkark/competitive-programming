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
    int[] vx = [-1, 0, 1, 0];
    int[] vy = [0, -1, 0, 1];
    while(true) {
        int N = readln.chomp.to!int;
        if (N == 0) break;
        int[2][int] aa;
        aa[0] = [0, 0];
        int[] maxPos = [0, 0];
        int[] minPos = [0, 0];
        foreach(int i; 1..N) {
            int[] input = readln.split.to!(int[]);
            int n = input[0];
            int d = input[1];
            aa[i] = [aa[n][0]+vx[d], aa[n][1]+vy[d]];
            maxPos[0] = max(maxPos[0], aa[i][0]);
            maxPos[1] = max(maxPos[1], aa[i][1]);
            minPos[0] = min(minPos[0], aa[i][0]);
            minPos[1] = min(minPos[1], aa[i][1]);
        }
        writeln(maxPos[0]-minPos[0]+1, " ", maxPos[1]-minPos[1]+1);
    }
}
