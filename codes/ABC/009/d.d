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
    int K = input[0];
    int M = input[1]-1;
    uint[] A = readln.split.to!(uint[]);
    uint[] C = readln.split.to!(uint[]);

    if (M<K) {
        A[M].writeln;
    } else {
        uint[][] matrix = new uint[][](K, K);
        matrix[0] = C;
        foreach(i; 1..K) matrix[i][i-1] = ~0u;
        mult(pow(matrix, M-K+1), A.reverse.map!(e=>[e]).array).front.front.writeln;
    }
}

uint[][] pow(uint[][] m, int n) {
    assert(m.length==m.front.length);
    uint[][] result = new uint[][](m.length, m.length);
    foreach(i; 0..m.length) result[i][i] = ~0u;
    for(; n>0; n>>=1) {
        if (n&1) result = mult(result, m);
        m = mult(m, m);
    }
    return result;
}

uint[][] mult(uint[][] m1, uint[][] m2) {
    assert(m1.front.length==m2.length);
    uint[][] result = new uint[][](m1.length, m2.front.length);
    foreach(i; 0..m1.length) foreach(j; 0..m2.front.length) {
        foreach(k; 0..m2.length) {
            result[i][j] ^= m1[i][k]&m2[k][j];
        }
    }
    return result;
}
