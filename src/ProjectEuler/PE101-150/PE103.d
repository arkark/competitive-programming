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
    int diff = 3;
    int[] ary = [20, 31, 38, 39, 40, 42, 45];
    int minimum = int.max;
    int[] ans;
    foreach(i; -diff..diff)foreach(j; -diff..diff)foreach(k; -diff..diff)foreach(l; -diff..diff)foreach(m; -diff..diff)foreach(n; -diff..diff)foreach(o; -diff..diff) {
        int[] _ary = [ary[0]+i, ary[1]+j, ary[2]+k, ary[3]+l, ary[4]+m, ary[5]+n, ary[6]+o];
        int temp = check(7, _ary);
        if (temp>0) {
            if (temp < minimum) {
                ans = _ary;
                minimum = temp;
            }
            _ary.writeln;
        }
    }
    reduce!((a,b) => a~b.to!string)("", ans).writeln;
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
