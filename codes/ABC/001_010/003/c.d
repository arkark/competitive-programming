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

void main() {
    int K = readln.split[1].to!int;
    writefln("%0.6f", reduce!("(a+b)/2")(0.0, readln.split.to!(double[]).sort.reverse.take(K).reverse));
}
