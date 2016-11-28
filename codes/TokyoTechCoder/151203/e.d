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
        int N = readln.chomp.to!int;
        if (N==0) break;
        char[] str = readln.chomp.to!(char[]);
        int ba = 0;
        int[] huda = new int[N];
        for(int i=0, j=0; i<str.length; i++, j=(j+1)%N) {
            huda[j]++;
            switch(str[i]) {
            case 'M':
                break;
            case 'S':
                ba += huda[j];
                huda[j] = 0;
                break;
            case 'L':
                huda[j] += ba;
                ba = 0;
                break;
            default:
            }
        }
        writeln(huda.sort.to!string.tr("[],", "", "d"), " ", ba);
    }
}
