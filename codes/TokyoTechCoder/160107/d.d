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
    while(true) {
        int[] N = readln.chomp.to!(char[]).map!(a=>(a-'0').to!int).array;
        if (N==[0, 0, 0, 0]) break;

        if (N[0]==N[1] && N[1]==N[2] && N[2]==N[3]) {
            writeln("NA");
            continue;
        }

        int cnt = 0;
        while(N!=[6, 1, 7, 4]) {
            int[] L = N.sort!("a>b").array;
            int[] S = N.sort!("a<b").array;
            N = subtract(L, S);
            cnt++;
        }
        cnt.writeln;
    }
}
int[] subtract(int[] a, int[] b) {
    string num = (a.to!(string[]).reduce!((a,b)=>a~b).to!int - b.to!(string[]).reduce!((a,b)=>a~b).to!int).to!string;
    while(num.length<4) {
        num = "0"~num;
    }
    return num.to!(char[]).map!(a=>(a-'0').to!int).array;
}
