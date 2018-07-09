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
import std.datetime;

long prime = 101;
int D, N, L;
char[] kaizan;
long[] ph;
bool[char][] set;
RedBlackTree!(char[], "a < b", false) rbt;
void main() {
    while(true) {
        int[] input = readln.split.to!(int[]);
        if (input == [0, 0]) break;
        D = input[0];
        N = input[1];
        kaizan = readln.chomp.to!(char[]);
        ph = new long[N];
        char[][] pieces = new char[][N];
        foreach(int i; 0..N) pieces[i] = readln.chomp.to!(char[]);
        L = pieces[0].length.to!int;
        set = new bool[char][L];
        foreach(int i; 0..N) {
            foreach(int j; 0..L) {
                foreach(int k; j..L) {
                    set[k][pieces[i][j]] = true;
                }
                ph[i] += pieces[i][j]*prime^^(L-1-j);
            }
        }
        ph.sort;

        rbt = redBlackTree!(char[]);
        rec(0, 0, kaizan, 0, 0, -10, -10, -10);
        rbt.length.writeln;
        if (rbt.length <= 5) {
            while(!rbt.empty) {
                rbt.front.writeln;
                rbt.removeFront;
            }
        }
    }
}

void rec(int depth, int d, char[] str, int flg, long th, int insertedIndex, int replacedIndex, int removedIndex) {
    if (depth == str.length) {
        if (d<D) {
            // insert back
            foreach(char c; set[min(depth, L-1)].byKey) {
                char[] _str = str[0..depth] ~ c ~ str[depth..$];
                rec(depth, d+1, _str, flg, th, depth, replacedIndex, removedIndex);
            }
        }
        if (flg == ~(~0<<L)) rbt.insert(str);
    } else {
        if (d<D) infect(depth, d, str, flg, th, insertedIndex, replacedIndex, removedIndex);
        flg = (flg<<1) & ~(1<<L);
        th = th*prime + str[depth];
        if (depth>=L) th -= str[depth-L]*prime^^L;
        if (depth>=L-1) flg = flg | rabinKarp(th);
        if (depth<L-1 || flg & 1<<(L-1)) {
            rec(depth+1, d, str, flg, th, insertedIndex, replacedIndex, removedIndex);
        }
    }
}

void infect(int depth, int d, char[] str, int flg, long th, int insertedIndex, int replacedIndex, int removedIndex) {
    // insert
    if (depth!=insertedIndex && depth!=replacedIndex && depth!=removedIndex) {
        foreach(char c; set[min(depth, L-1)].byKey) {
            if (c == str[depth] && depth<str.length-1 && str[depth]==str[depth+1]) continue;
            char[] _str = str[0..depth] ~ c ~ str[depth..$];
            rec(depth, d+1, _str, flg, th, depth, replacedIndex, removedIndex);
        }
    }
    // replace
    if (depth!=insertedIndex && depth!=insertedIndex+1 && depth!=replacedIndex && depth!=removedIndex) {
        foreach(char c; set[min(depth, L-1)].byKey) {
            if (c == str[depth]) continue;
            char[] _str = str.dup;
            _str[depth] = c;
            rec(depth, d+1, _str, flg, th, insertedIndex, depth, removedIndex);
        }
    }
    // remove
    for (int i=0; i<1; i++) {
        if (depth==insertedIndex) continue;
        if (depth==insertedIndex+1) continue;
        if (depth==replacedIndex) continue;
        if (depth<str.length-2 && str[depth]==str[depth+1] && str[depth+1]==str[depth+2]) continue;
        if (D-d==1 && depth<str.length-1 && str[depth]==str[depth+1]) continue;
        char[] _str = str[0..depth] ~ str[depth+1..$];
        rec(depth, d+1, _str, flg, th, insertedIndex, replacedIndex, depth);
    }
}

int rabinKarp(long th) {
    int left = 0;
    int right = N-1;
    while (left<=right) {
        int center = (left+right)/2;
        if (ph[center] > th) {
            right = center-1;
        } else if (ph[center] < th) {
            left = center+1;
        } else {
            return ~(~0<<L);
        }
    }
    return 0;
}
