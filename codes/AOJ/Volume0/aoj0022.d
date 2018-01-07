import std.stdio, std.string, std.algorithm, std.conv;
const long INF = long.max/3;

void main() {
    while(solve()){}
}

bool solve() {
    int N = readln.chomp.to!int;
    if (N == 0) return false;

    long[] as = new long[N];
    foreach(i; 0..N) {
        as[i] = readln.chomp.to!long;
    }

    long res = -INF;
    long s = 0;
    foreach(i; 0..N) {
        s = max(as[i], s + as[i]);
        res = max(res, s);
    }
    res.writeln;

    return true;
}
