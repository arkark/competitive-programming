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
    int N = readln.chomp.to!int;
    foreach(i; 0..N) {
        bfs(readln.split.to!(int[])).writeln;
    }
}

int bfs(int[] ary) {
    auto list = DList!(Tuple!(int, int[]))(tuple(0, ary));
    while(!list.empty) {
        auto t = list.front;
        int depth = t[0];
        int[] vec = t[1];
        list.removeFront;
        if (check(vec)) return depth;
        {
            int[] v = vec.dup;
            swap(v[0], v[27]);
            swap(v[1], v[28]);
            swap(v[2], v[29]);
            swap(v[14], v[15]);
            swap(v[18], v[20]);
            list.insertBack(tuple(depth+1, v));
        } {
            int[] v = vec.dup;
            swap(v[2], v[21]);
            swap(v[5], v[24]);
            swap(v[8], v[27]);
            swap(v[11], v[18]);
            swap(v[12], v[14]);
            list.insertBack(tuple(depth+1, v));
        } {
            int[] v = vec.dup;
            swap(v[0], v[23]);
            swap(v[3], v[26]);
            swap(v[6], v[29]);
            swap(v[9], v[20]);
            swap(v[15], v[17]);
            list.insertBack(tuple(depth+1, v));
        } {
            int[] v = vec.dup;
            swap(v[6], v[21]);
            swap(v[7], v[22]);
            swap(v[8], v[23]);
            swap(v[12], v[17]);
            swap(v[9], v[11]);
            list.insertBack(tuple(depth+1, v));
        }
    }
    return 8;
}

bool check(int[] ary) {
    return ary.group.map!(a => a[1]).array == [9, 3, 3, 3, 3, 9];
}
