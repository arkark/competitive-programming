import std.stdio;
import std.string;
import std.conv;
import std.typecons;
import std.algorithm;
import std.functional;
import std.bigint;
import std.numeric;
import std.array;

void main() {
    int m = readln.chomp.to!int;
    int w = 0;
    if (m<100) {
        w = 0;
    } else if (m <= 5000) {
        w = m/100;
    } else if (m >= 6000 && m <= 30000) {
        w = m/1000+50;
    } else if (m >= 35000 && m <= 70000) {
        w = (m/1000-30)/5+80;
    } else if (m >= 70000) {
        w = 89;
    }
    writeln(w<10 ? "0"~(to!string(w)):(to!string(w)));
}
