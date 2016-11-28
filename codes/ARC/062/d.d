import std.stdio, std.string, std.algorithm, std.functional;

void main() {
    readln.chomp.map!(a => a=='p' ? -1:1).sum.pipe!"a/2".writeln;
}
