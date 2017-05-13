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

int[] dx = [-1,+1,0,0];
int[] dy = [0,0,+1,-1];
void main() {
    int[] str = readln.chomp.map!(c => c=='L'?0:c=='R'?1:c=='U'?2:c=='D'?3:-1).array;
    int T = readln.chomp.to!int;
    int[] pos = [0,0];
    int s = 0;
    foreach(i, e; str) {
        if (e<0) {
            s++;
        } else {
            pos[] += [dx[e], dy[e]];
        }
    }
    if (T==1) writeln(pos[0].abs + pos[1].abs + s);
    if (T==2) {
        int ans = pos[0].abs + pos[1].abs - s;
        if (ans > 0) {
            ans.writeln;
        } else {
            writeln((pos[0].abs + pos[1].abs - s)%2==0 ? 0:1);
        }
    }
}
struct Pos {int x,y;}
