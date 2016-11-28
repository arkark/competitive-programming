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

int INF = int.max;
void main() {
  int N = readln.chomp.to!int;

  int[] ary = new int[N+1];
  ary[0..$] = INF;
  int l = 0;
  int r = 1;
  foreach(i; 0..N+1) {
    if (!(l<r)) break;
    foreach(j; l..r) {
      if (j>N) break;
      ary[j] = min(ary[j], i);
    }
    l = r;
    r = r+i+1;
  }
  int k = N;
  while(k > 0) {
    ary[k].writeln;
    k -= ary[k];
  }
}
