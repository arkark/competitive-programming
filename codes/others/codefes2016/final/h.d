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
void times(alias pred)(int n) {
    foreach(i; 0..n) pred();
}
auto rep(alias pred, T = typeof(pred()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

void main() {
  int N = readln.chomp.to!int;
  int[] a = readln.split.to!(int[]);
  int M = readln.chomp.to!int;
  if (M > 1) return;
  a ~= readln.chomp.to!int;
  a ~= 0;

  int[] ary = new int[N];
  int maxV = -int.max;
  int[] index = new int[N];
  int maxI = -1;
  ary.back = 0;
  for(int i=N-2; i>=0; i--) {
    int v = a[i+2]-ary[i+1];
    if (v > maxV) {
      maxV = v;
      maxI = i+2;
      ary[i] = maxV;
    } else {
      ary[i] = maxV;
    }
    index[i] = maxI;
  }
  int i = 0; int j=0;
  int num1, num2;
  int po = 0;
  while(abs(i-j)==1 && (i==N-1 || j==N-1)) {
    if (po%2==0) {
      num1 = ary[i];
      num2 = a[i..index[i]-1].sum;
      i = index[i];
      j = i-1;
    } else {
      num2 = ary[j];
      num1 = a[j..index[j]-1].sum;
      j = index[j];
      i = j-1;
    }
    po++;
  }
  index.writeln;
  (num1-num2).writeln;
}
