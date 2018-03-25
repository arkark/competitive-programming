import std.stdio : readln, writeln;
import std.conv : to;
import std.string : chomp;
import std.range : retro, generate, back, array, take;
import std.algorithm : reduce, min, startsWith;
import std.array : empty;
import std.functional : pipe;

void main() {
    readln.chomp.retro.to!string.pipe!(
        s => generate!(
            () => s = s.reduce!(
                (a, b) => a.startsWith(b) ? a[min($, b.length)..$] : a
            )(["maerd", "remaerd", "esare", "resare"])
        ).take(20000).array.back.empty ? "YES" : "NO"
    ).writeln;
}
