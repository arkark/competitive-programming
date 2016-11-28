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
    string str = readln.chomp;
    string ans = "";
    string[] boin = ["w", "", "k", "s", "t", "n", "h", "m", "y", "r"];
    string[] shiin = ["a", "i", "u", "e", "o"];
    for (int i=0; i<str.length; i+=2) {
        if (str[i..i+2] == ['0', 'U']) {
            ans ~= "nn";
        } else {
            ans ~= boin[str[i]-'0'];
            switch(str[i+1]) {
            case 'T': ans ~= shiin[0]; break;
            case 'L': ans ~= shiin[1]; break;
            case 'U': ans ~= shiin[2]; break;
            case 'R': ans ~= shiin[3]; break;
            case 'D': ans ~= shiin[4]; break;
            default:
            }
        }
    }
    ans.writeln;
}
