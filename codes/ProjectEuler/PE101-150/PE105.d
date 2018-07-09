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
    int N = 100;
    int ans = 0;
    foreach(i; 0..N) {
        int[] input = readln.chomp.split(",").to!(int[]);
        ans += max(0, check(input.length, input));
    }
    ans.writeln;
}

int check(int size, int[] ary) {
    foreach(i; 0..3^^size) {
        int num1, num2, sum1, sum2;
        foreach(j; 0..size) {
            int _i = i;
            foreach(k; 0..j) {
                _i /= 3;
            }
            _i %= 3;
            if (_i==1) {
                num1++;
                sum1+=ary[j];
            }
            if (_i==2) {
                num2++;
                sum2+=ary[j];
            }
        }
        if (num1*num2 == 0) continue;
        if (sum1==sum2) return -1;
        if (num1>num2 && sum1<sum2) return -1;
        if (num1<num2 && sum1>sum2) return -1;
    }
    return ary.sum;
}
