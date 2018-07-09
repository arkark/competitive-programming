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
void times(void delegate() pred)(int n) {
    foreach(i; 0..n) pred();
}
T[] rep(T)(int n, T delegate() pred) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

int[] dx = [-1,-1,-1,0,0,0,1,1,1];
int[] dy = [-1,0,1,-1,0,1,-1,0,1];
int H, W;
void main() {
    readf("%d %d\n", &H, &W);
    bool[][] input = H.rep(()=>readln.chomp.map!"a=='#'".array);
    bool flg = input.f(false).f(true) == input;
    writeln(flg ? "possible":"impossible");
    if (flg) input.f(false).each!(a => a.map!(b => b?'#':'.').array.writeln);
}
bool[][] f(bool[][] grid, bool flg) {
    return H.iota.map!(i => W.iota.map!(j => (9.iota.map!(k=>[i+dy[k], j+dx[k]]).any!(a => 0<=a[0]&&a[0]<H && 0<=a[1]&&a[1]<W && grid[a[0]][a[1]]==flg)) ? flg:!flg).array).array;
}
