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

int[] A, B;
int K;
void main() {
    string[] input = readln.split;
    A = input[0].to!(char[]).map!(a=>(a-'0').to!int).array;
    B = input[1].to!(char[]).map!(a=>(a-'0').to!int).array;
    K = input[2].to!int;
    while (B.length < A.length) B = 0~B;
    A.reverse; B.reverse;
    func(0, 0, new int[A.length], 0).writeln;
}
long func(int index, int b, int[] C, int k) {
    if (index == A.length) {
        return connect(C);
    } else {
        long result;
        if (A[index] - b >= B[index]) {
            C[index] = A[index]-b-B[index];
            result = max(result, func(index+1, 0, C, k));
        } else {
            C[index] = A[index]-b+10-B[index];
            result = max(result, func(index+1, 1, C, k));
            if (k+1 <= K) {
                result = max(result, func(index+1, 0, C, k+1));
            }
        }
        return result;
    }
}
long connect(int[] C) {
    long result = 0;
    for(int i=0; i<C.length; i++) {
        result += C[i]*10^^i;
    }
    return result;
}
