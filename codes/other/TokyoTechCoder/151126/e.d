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
    int[char] count;
    for(int i=0; i<str.length; i++) {
        count[str[i]]++;
    }
    int odd = 0;
    char key;
    foreach(char k, int v; count) {
        if (v%2 != 0) {
            odd++;
            key = k;
        }
    }
    if (odd > 1) {
        writeln(0);
    } else {
        count[key]--;
        long x = 0;
        long y = 1;
        foreach(int v; count.values) {
            x += v/2;
            y *= fact(v/2);
        }
        writeln(fact(x)/y);
    }
}
long factorial(long n) {
    if (n==0) return 1;
    return n*factorial(n-1);
}
alias memoize!factorial fact;
