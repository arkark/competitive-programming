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
    int[char] aa;
    readln.chomp.each!(c => aa[c]++);
    int[] ary = aa.values;

    int num1 = ary.map!"a/2".sum;
    int num2 = ary.count!"a%2==1".to!int;
    writeln(num2==0 ? 2*num1 : (num1/num2)*2+1);
}
