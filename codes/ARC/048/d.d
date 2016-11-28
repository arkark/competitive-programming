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
    int[] input = readln.split.to!(int[]);
    int N = input[0];
    int Q = input[1];
    Vertex[] vertices = new Vertex[N];
    foreach(i; 0..N) {
        vertices[i] = Vertex(i);
    }
    foreach(i; 0..N-1) {
        input = readln.split.to!(int[]).map!"a-1".array;
        vertices[input[0]].edges ~= Edge(input[0], input[1]);
        vertices[input[1]].edges ~= Edge(input[1], input[0]);
    }
    int x = -1;
    int[] y = [];
    foreach(i; 0..N) {
        if (vertices[i].edges.length==3) x = i;
        if (vertices[i].edges.length==1) y ~= i;
    }
    bool[] takoyaki = readln.chomp.to!(char[]).map!("a=='1'").array;

    if (x==-1) {
        x = y.back;
        y = y[0..$-1];
    }

    const int INF = 1<<30;
    int[][] ary = new int[][](N, N);
    int[] dist1 = new int[N];
    int[] dist2 = new int[N];
    bool[] flgAry = new bool[N];
    foreach(ref a; ary) a[] = INF;
    auto list = DList!int(y);
    while(!list.empty) {
        int index = list.front;
        list.removeFront;
        int now = index;
        bool flg = false;
        ary[index][now] = 0;
        int[] stack = [];
        while(true) {
            if (takoyaki[now]) flg = true;
            int pre = now;
            now = vertices[now].edges.front.g;
            foreach(edge; vertices[now].edges) {
                if (edge.g != now) {
                    vertices[now].edges = [edge];
                    break;
                }
            }
            ary[index][now] = ary[index][pre] + (flg ? 1:2);
            stack ~= now;
            dist1[index]++;
            if (now == x) {
                stack.reverse;
                dist2[index] = 0;
                flgAry[index] = flg;
                flg = false;
                foreach(i; stack) {
                    if (takoyaki[i] == true) flg = true;
                    dist2[index] += flg ? 1:2;
                }
                break;
            } else {
                list.insertBack(now);
            }
        }
    }
    ary[x][x] = 0;
    dist2[x] = 0;
    y.writeln;
    takoyaki.writeln;

    ary[0][4].writeln;
        ary[0][1].writeln;
    dist2[4].writeln;

    ary[0][1].writeln;
    dist2[6].writeln;
    dist1[]

    foreach(i; 0..Q) {
        input = readln.split.to!(int[]).map!"a-1".array;
        int s = input[0];
        int g = input[1];
        writeln(min(ary[s][g], ary[s][x]+(flgAry[i] ? dist1[g]:dist2[g])));
    }
}

struct Vertex {
    int index;
    Edge[] edges = [];
}

struct Edge {
    int s;
    int g;
}
