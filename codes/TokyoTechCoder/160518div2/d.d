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
    string c = "SHCD";
    int[dchar] aa1 = zip(c, 4.iota).assocArray;
    dchar[int] aa2 = zip(4.iota, c).assocArray;
    bool[][] flag = new bool[][](4, 13);
    readln.chomp.to!int.iota.map!(_ => readln.split).each!(a => flag[aa1[a[0].to!dchar]][a[1].to!int-1] = true);
    foreach(i; 0..4) foreach(j; 0..13) {
        if (!flag[i][j]) writeln(aa2[i]~" "d~(j+1).to!dstring);
    }
}
