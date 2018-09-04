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
import std.datetime;
void times(int n, void delegate() pred) {
    foreach(i; 0..n) pred();
}
T[] rep(T)(int n, T delegate() pred) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

void main() {
    (n){
        return {
            string res = "b";
            string str = "abc";
            foreach(i; 0..n) {
                res = str[($-i%3)%3]~res~str[(i+$-1)%$];
            }
            return res;
        }() == readln.chomp ? n:-1;
    }((readln.chomp.to!int-1)/2).writeln;
}
