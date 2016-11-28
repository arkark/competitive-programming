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
    int R = input[1];
    int L = input[2];
    Node[] nodes = new Node[N];
    foreach(int i; 0..N) nodes[i] = Node(i);
    auto rbt = redBlackTree!("a.score==b.score ? a.id<b.id : a.score>b.score")(nodes[0]);
    int preT = 0;
    foreach(int i; 0..R) {
        input = readln.split.to!(int[]);
        int d = input[0]-1;
        int t = input[1];
        int x = input[2];

        int j = rbt.front.id;
        rbt.removeFront;
        nodes[j].time += t-preT;
        rbt.insert(nodes[j]);
        rbt.removeKey(nodes[d]);
        nodes[d].score += x;
        rbt.insert(nodes[d]);
        preT = t;
    }
    nodes[rbt.front.id].time += L-preT;
    multiSort!("a.time>b.time", "a.id<b.id")(nodes);
    writeln(nodes.front.id+1);
}
struct Node{
    int id, time, score;
    this(int id) {
        this.id = id;
        time = 0;
        score = 0;
    }
}
