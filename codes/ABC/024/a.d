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
void times(int n, void delegate() pred) {
    foreach(i; 0..n) pred();
}
T[] rep(T)(int n, T delegate() pred) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

void main() {
    int A, B, C, K, S, T;
    readf("%d %d %d %d\n%d %d", &A, &B, &C,& K, &S, &T);
    writeln(A*S+B*T - (S+T>=K ? C*(S+T):0));
}
