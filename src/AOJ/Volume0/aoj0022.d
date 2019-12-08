import std.stdio;
import std.string;
import std.algorithm;
import std.functional;
import std.conv;

enum long INF = long.max/5;

void main() {
  while(solve()){}
}

bool solve() {
  int n = readln.chomp.to!int;
  if (n == 0) return false;

  long[] as = new long[n];
  foreach(i; 0..n) {
    as[i] = readln.chomp.to!long;
  }

  kadane!(
    long, max, -INF, "a+b", 0
  )(as).writeln;

  return true;
}

T kadane(
  T,              // 型
  alias plusFun,  // 加法の２項演算
  T plusIdentity, // 加法の単位元
  alias multFun,  // 乗法の２項演算
  T multIdentity  // 乗法の単位元
)(T[] as) {
  alias _plusFun = binaryFun!plusFun;
  alias _multFun = binaryFun!multFun;
  T res = plusIdentity;
  T s = multIdentity;
  foreach(a; as) {
    s = _plusFun(_multFun(s, a), a);
    res = _plusFun(res, s);
  }
  return res;
}
