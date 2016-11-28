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

int N, M;
void main() {
    while(true) {
        int[] input = readln.split.to!(int[]);
        if (input == [0, 0]) break;
        N = input[0];
        M = input[1];
        Edge[] edges = new Edge[M];
        foreach(int i; 0..M) {
            input = readln.split.to!(int[]);
            int a = input[0];
            int b = input[1];
            edges[i] = Edge(input[2], min(a, b), max(a, b));
        }
        sort!("a.cost<b.cost")(edges);
        int[] usedNode = [0];
        int ans = 0;
        foreach(int i; 1..N) {
            for (int j=0; j<edges.length; j++) {
                bool flg1 = usedNode.canFind(edges[j].from);
                bool flg2 = usedNode.canFind(edges[j].to);
                if (flg1 && !flg2) {
                    usedNode ~= edges[j].to;
                    ans += edges[j].cost;
                    break;
                } else if (!flg1 && flg2)  {
                    usedNode ~= edges[j].from;
                    ans += edges[j].cost;
                    break;
                }
            }
        }
        ans.writeln;
    }
}
struct Edge {
    int cost;
    int from, to;
    this(int cost, int from, int to) {
        this.cost = cost;
        this.from = from;
        this.to = to;
    }
}
