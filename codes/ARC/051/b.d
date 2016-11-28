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
    int N = readln.chomp.to!int;
    writeln(fib(N-1), " ", fib(N));
}
long fib(int n) {
    return n < 2 ? 1 : memoize!fib(n - 2) + memoize!fib(n - 1);
}
