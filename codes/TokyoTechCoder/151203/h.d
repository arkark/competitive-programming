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
    string[] input = readln.split;
    int N = input[0].to!int;
    int Q = input[1].to!int;
    Obj[] objects = new Obj[N];
    foreach(int i; 0..N) objects[i] = Obj(i, readln.chomp.to!long);
    auto leaders = redBlackTree!("a.s==b.s ? a.id<b.id : a.s>b.s", Obj)([]);
    foreach(int i; 0..Q) {
        input = readln.split;
        switch(input[0]) {
        case "ADD":
            int a = input[1].to!int-1;
            leaders.insert(objects[a]);
            break;
        case "REMOVE":
            int a = input[1].to!int-1;
            leaders.removeKey(objects[a]);
            break;
        case "CHECK":
            long x = input[1].to!long;
            long left = 0, right = 2*10^^9;
            long result = -1;
            while(left < right) {
                long center = (left+right)/2;
                long count = 0;
                auto rbt = redBlackTree!("a.s==b.s ? a.id<b.id : a.s<b.s")(objects);
                foreach(Obj o; leaders) {
                    count += rbt.upperBound(Obj(-1, o.s+1)).array.length;
                    rbt.removeKey(rbt.upperBound(Obj(-1, o.s-center)));
                }
                count += rbt.length;
                if (count <= x) {
                    result = right = center;
                } else {
                    if (left == center) break;
                    left = center;
                }
            }
            writeln(result<0 ? "NA":result.to!string);
            break;
        default:
        }
    }
}
struct Obj{
    long id, s;
    this(long id, long s) {
        this.id = id;
        this.s = s;
    }
}
