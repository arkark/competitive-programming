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

void main() {
    int[char] aa;
    string alphabet = "abcdefghijklmnopqrstuvwxyz";
    alphabet.each!(c => aa[c]=0);
    while(true) {
        char[] str = readln.chomp.to!(char[]);
        if (stdin.eof) break;
        str.each!(c => aa[std.ascii.toLower(c)]++);
    }
    alphabet.each!(c => writeln(c~" : "~aa[c].to!string));
}
