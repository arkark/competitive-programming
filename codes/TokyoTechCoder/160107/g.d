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
        int M = readln.chomp.to!int;
        if (M==0) break;
        int n = readln.chomp.to!int;
        int[] d = new int[n+2];
        foreach(i; 0..n) d[i+1] = readln.chomp.to!int;
        bool[][] edges = new bool[][](d.length, d.length);
        bool[][] edges_reverse = new bool[][](d.length, d.length);
        foreach(i; 0..d.length) {
            foreach(j; 1..M+1) {
                int k = min(d.length-1, i+j).to!int;
                k += d[k];
                k = max(0, min(d.length-1, k));
                edges[i][k] = true;
                edges_reverse[k][i] = true;
            }
        }

        bool[] flg1 = new bool[d.length];
        flg1[0] = true;
        auto list = DList!(int)(0);
        while(!list.empty) {
            int id = list.front;
            list.removeFront;
            foreach(i, e; edges[id]) {
                if (e && !flg1[i]) {
                    flg1[i] = true;
                    list.insertBack(i.to!int);
                }
            }
        }
        bool[] flg2 = new bool[d.length];
        flg2[$-1] = true;
        list.insertBack(d.length.to!int-1);
        while(!list.empty) {
            int id = list.front;
            list.removeFront;
            foreach(i, e; edges_reverse[id]) {
                if (e && !flg2[i]) {
                    flg2[i] = true;
                    list.insertBack(i.to!int);
                }
            }
        }

        foreach(i; 0..d.length) {
            if (flg1[i] && !flg2[i]) {
                writeln("NG");
                break;
            }
            if (i == d.length-1) {
                writeln("OK");
            }
        }
    }
}
