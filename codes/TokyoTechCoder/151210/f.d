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

long INF = 1L<<60;
int N, K;
int[][] toIndex;
long[] c, r;
void main() {
    string[] input = readln.split;
    N = input[0].to!int;
    K = input[1].to!int;
    c = new long[N];
    r = new long[N];
    foreach(int i; 0..N) {
        input = readln.split;
        c[i] = input[0].to!long;
        r[i] = input[1].to!long;
    }
    toIndex = new int[][](N, 0);
    foreach(int i; 0..K) {
        input = readln.split;
        toIndex[input[0].to!int-1] ~= input[1].to!int-1;
        toIndex[input[1].to!int-1] ~= input[0].to!int-1;
    }
    bool[][] passableOnce = new bool[][](N, N);
    foreach(int i; 0..N) {
        passableOnce[i] = getPassableOnce(i);
    }

    Node[] nodes = new Node[N];
    foreach(int i; 0..N) {
        nodes[i] = new Node(i, c[i]);
    }
    nodes.front.value = 0;
    auto rbtree = redBlackTree!("a.value==b.value ? a.index<b.index : a.value<b.value")(nodes.front);
    while(!rbtree.empty) {
        Node e = rbtree.front;
        rbtree.removeFront;
        e.done = true;
        foreach(int i; 0..N) {
            if (!nodes[i].done && passableOnce[e.index][i]) {
                if (e.value+e.cost < nodes[i].value) {
                    rbtree.removeKey(nodes[i]);
                    nodes[i].value = e.value+e.cost;
                    rbtree.insert(nodes[i]);
                }
            }
        }
    }
    nodes.back.value.writeln;
}
bool[] getPassableOnce(int from) {
    long[] ary = new long[N];
    ary[] = INF;
    ary[from] = 0;
    auto list = DList!(int)(from);
    while(!list.empty) {
        int i = list.front;
        list.removeFront;
        if (ary[i] >= r[from]) break;
        foreach(int e; toIndex[i]) {
            if (ary[e] == INF) {
                ary[e] = ary[i]+1;
                list.insert(e);
            }
        }
    }
    return ary.map!(a=>a<INF).array;
}
class Node{
    int index;
    long cost;
    bool done = false;
    long value;
    this(int index, long cost) {
        this.index = index;
        this.cost = cost;
        this.value = INF;
    }
    override string toString() const {return ""; }
}
