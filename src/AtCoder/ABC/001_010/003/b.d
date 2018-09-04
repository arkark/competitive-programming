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

void main() {
    string S = readln.chomp;
    string T = readln.chomp;
    bool flg = true;
    string atcoder = "atcoder";
    for (int i=0; i<S.length; i++) {
        if (S[i] == T[i]) continue;
        if (S[i] == '@' && atcoder.canFind(T[i])) continue;
        if (T[i] == '@' && atcoder.canFind(S[i])) continue;
        flg = false;
    }
    writeln(flg ? "You can win":"You will lose");
}
