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
    writeln(func(input[1]) - func((input[0].to!long-1).to!string));
}
long func(string str) {
    int[] ary = str.to!(char[]).map!(a => (a-'0').to!int).array;
    int[] f = ary.find!(a => a==4||a==9);
    if (f.length > 0) {
        f[0]--;
        f[1..$] = 8;
    }
    ary = ary.map!(a => a>4 ? a-1:a).array;
    long result = 0;
    for (int i=0; i<ary.length; i++) {
        result += 8L^^i*ary[$-i-1];
    }
    return str.to!long - result;
}
